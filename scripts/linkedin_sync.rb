#!/usr/bin/env ruby
# frozen_string_literal: true
#
# linkedin_sync.rb -- sync LinkedIn posts (via an RSS feed) into this Jekyll blog.
#
# Every feed item is identified by its stable RSS <guid> and recorded in
# _data/linkedin.yml. An item that already has a ledger entry is NEVER imported
# again, no matter what you do to the generated file. That is what makes it safe
# to retitle, rename, move to _drafts/, hand-edit or delete a post: the daily
# GitHub Action will not undo your work.
#
# Usage:
#   ruby scripts/linkedin_sync.rb list
#   ruby scripts/linkedin_sync.rb sync [--dry-run]
#   ruby scripts/linkedin_sync.rb status
#   ruby scripts/linkedin_sync.rb exclude <ref>
#   ruby scripts/linkedin_sync.rb include <ref>
#   ruby scripts/linkedin_sync.rb refresh <ref> [--force]
#
# <ref> is a guid prefix, a LinkedIn activity id, or any substring of the title
# or filename -- e.g. `exclude dogs`.
#
# Feed URL comes from --feed (a URL or a local file), else $LINKEDIN_RSS_URL,
# else the .linkedin-rss-url file in the repo root.

begin
  require 'rexml/document'
rescue LoadError
  abort "Missing the 'rexml' gem. Install it with:  gem install --user-install rexml"
end

require 'open-uri'
require 'uri'
require 'yaml'
require 'time'
require 'cgi'
require 'fileutils'
require 'optparse'

ROOT        = File.expand_path('..', __dir__)
POSTS_DIR   = File.join(ROOT, '_posts')
DRAFTS_DIR  = File.join(ROOT, '_drafts')
LEDGER_PATH = File.join(ROOT, '_data', 'linkedin.yml')
IMAGE_DIR   = File.join(ROOT, 'images', 'blog', 'linkedin')
IMAGE_URL   = '/images/blog/linkedin'
FEED_FILE   = File.join(ROOT, '.linkedin-rss-url')

# Jekyll interprets post dates in the site's timezone, and derives the permalink
# from it. Adopt the same zone here so the filename, the `date:` field and the
# URL agree -- and so a local run and the (UTC) GitHub Actions runner agree too.
def apply_site_timezone!
  config = File.join(ROOT, '_config.yml')
  return unless File.exist?(config)

  tz = begin
    (YAML.safe_load(File.read(config), permitted_classes: [Date, Time], aliases: true) || {})['timezone']
  rescue StandardError
    nil
  end
  ENV['TZ'] = tz if tz && !tz.to_s.empty?
end

LEDGER_HEADER = <<~HEADER
  # Record of every LinkedIn feed item this blog has ever seen.
  # Managed by scripts/linkedin_sync.rb -- see README-LinkedIn.md.
  #
  # An item listed here is never re-imported, so editing or deleting the
  # generated post is safe. Set `status: excluded` to strike one for good.
HEADER

# --------------------------------------------------------------------------
# ledger
# --------------------------------------------------------------------------

def load_ledger
  return { 'items' => {} } unless File.exist?(LEDGER_PATH)

  data = YAML.safe_load(File.read(LEDGER_PATH), permitted_classes: [Date, Time]) || {}
  data['items'] ||= {}
  data
end

def save_ledger(ledger)
  items = ledger['items'].sort_by { |_guid, e| e['date'].to_s }.reverse.to_h
  FileUtils.mkdir_p(File.dirname(LEDGER_PATH))
  body = Psych.dump({ 'items' => items }, line_width: -1).sub(/\A---\n/, '')
  File.write(LEDGER_PATH, LEDGER_HEADER + body)
end

def rel(path)
  path.start_with?(ROOT) ? path[(ROOT.length + 1)..] : path
end

# --------------------------------------------------------------------------
# feed
# --------------------------------------------------------------------------

FeedItem = Struct.new(:guid, :url, :activity, :time, :description, :media_url,
                      keyword_init: true)

def feed_source(opts)
  src = opts[:feed] || ENV['LINKEDIN_RSS_URL']
  src = File.read(FEED_FILE).strip if (src.nil? || src.empty?) && File.exist?(FEED_FILE)
  if src.nil? || src.empty?
    abort <<~MSG
      No RSS feed configured. Provide one of:
        ruby scripts/linkedin_sync.rb <cmd> --feed https://rss.app/feeds/XXXX.xml
        export LINKEDIN_RSS_URL=https://rss.app/feeds/XXXX.xml
        echo https://rss.app/feeds/XXXX.xml > .linkedin-rss-url
    MSG
  end
  src
end

def read_feed(src)
  if src =~ %r{\Ahttps?://}
    URI.parse(src).open(read_timeout: 30, &:read)
  else
    abort "Feed file not found: #{src}" unless File.exist?(src)
    File.read(src)
  end
rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED => e
  abort "Could not fetch feed: #{e.message}"
end

def element_text(el, name)
  child = el.elements[name]
  return nil unless child

  child.texts.map(&:value).join.strip
end

def parse_feed(xml)
  doc = REXML::Document.new(xml)
  doc.elements.to_a('//channel/item').filter_map do |el|
    url  = element_text(el, 'link')
    guid = element_text(el, 'guid')
    guid = url if guid.nil? || guid.empty?
    next if guid.nil? || guid.empty?

    raw_date = element_text(el, 'pubDate') || element_text(el, 'dc:date')
    time = begin
      Time.parse(raw_date)
    rescue StandardError
      nil
    end
    next unless time

    media = el.elements["media:content[@medium='image']"] || el.elements['media:content']

    FeedItem.new(
      guid: guid,
      url: url,
      activity: url.to_s[/activity-(\d+)/, 1],
      time: time,
      description: element_text(el, 'description') ||
                   element_text(el, 'content:encoded') ||
                   element_text(el, 'title') || '',
      media_url: media&.attributes&.[]('url')
    )
  end
rescue REXML::ParseException => e
  abort "Feed is not valid XML: #{e.message.lines.first}"
end

# --------------------------------------------------------------------------
# html -> markdown-ish text
# --------------------------------------------------------------------------

def first_image_url(html)
  html[/<img[^>]+src=["']([^"']+)["']/i, 1]
end

def html_to_text(html)
  s = html.dup
  s = s.gsub(%r{<br\s*/?>}i, "\n")
  s = s.gsub(%r{<li[^>]*>}i, "\n- ")
  s = s.gsub(%r{</(?:p|div|li|h[1-6]|ul|ol)>}i, "\n\n")
  s = s.gsub(/<[^>]+>/, '')
  s = CGI.unescapeHTML(s)
  s = s.tr(" ", ' ')
  s = s.lines.map(&:rstrip).join("\n")
  s = s.gsub(/\n{3,}/, "\n\n")
  # A lone newline is only a soft break in markdown, so LinkedIn's single line
  # breaks would silently merge into the previous line. Make them hard breaks.
  s = s.split(/\n{2,}/).map { |para|
    para.lines.map(&:strip).reject(&:empty?).join("  \n")
  }.join("\n\n")
  # Don't let LinkedIn's plain text turn into kramdown headings or blockquotes.
  s = s.gsub(/^([#>])/, '\\\\\1')
  s.strip
end

def truncate_words(text, limit)
  return text if text.length <= limit

  cut = text[0, limit]
  cut = cut.sub(/\s\S*\z/, '') if cut.include?(' ')
  "#{cut.rstrip}…"
end

def derive_title(text)
  first_para = text.split("\n").find { |l| !l.strip.empty? }.to_s.strip
  sentence = (first_para[/\A.*?[.!?](?=\s|\z)/m] || first_para).strip
  title = if sentence.length <= 100
            sentence.sub(/\.\z/, '')
          else
            truncate_words(first_para, 70)
          end
  title = title.gsub(/[#*_`\[\]\\]/, '').squeeze(' ').strip
  title.empty? ? 'LinkedIn post' : title
end

def derive_excerpt(text, limit = 220)
  para = text.split(/\n\s*\n/).find { |p| !p.strip.empty? }.to_s
  truncate_words(para.gsub(/\s+/, ' ').gsub(/\\([#>])/, '\1').strip, limit)
end

def slugify(title, max = 50)
  s = title.downcase.gsub(/['’`]/, '').gsub(/[^a-z0-9]+/, '-').gsub(/\A-+|-+\z/, '')
  if s.length > max
    s = s[0, max]
    s = s.sub(/-[^-]*\z/, '') if s.count('-') > 1
  end
  s = s.gsub(/\A-+|-+\z/, '')
  s.empty? ? 'linkedin-post' : s
end

# --------------------------------------------------------------------------
# posts on disk
# --------------------------------------------------------------------------

def split_front_matter(content)
  m = content.match(/\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m)
  return [nil, content] unless m

  fm = begin
    YAML.safe_load(m[1], permitted_classes: [Date, Time]) || {}
  rescue StandardError
    nil
  end
  [fm, m[2]]
end

def post_files
  (Dir[File.join(POSTS_DIR, '**', '*.{md,markdown,html}')] +
   Dir[File.join(DRAFTS_DIR, '**', '*.{md,markdown,html}')]).reject { |f| f.end_with?('~') }
end

# guid => absolute path, by reading linkedin_guid out of front matter
def scan_posts_by_guid
  post_files.each_with_object({}) do |path, acc|
    fm, = split_front_matter(File.read(path))
    guid = fm && fm['linkedin_guid']
    acc[guid.to_s] = path if guid && !guid.to_s.empty?
  end
end

# --------------------------------------------------------------------------
# rendering
# --------------------------------------------------------------------------

def download_image(url, basename)
  FileUtils.mkdir_p(IMAGE_DIR)
  data = nil
  ctype = nil
  URI.parse(url).open(read_timeout: 30) do |f|
    data = f.read
    ctype = f.content_type
  end
  ext = case ctype
        when %r{image/jpe?g} then '.jpg'
        when %r{image/png}   then '.png'
        when %r{image/gif}   then '.gif'
        when %r{image/webp}  then '.webp'
        else File.extname(URI.parse(url).path)[/\A\.\w{2,4}\z/] || '.jpg'
        end
  path = File.join(IMAGE_DIR, basename + ext)
  File.binwrite(path, data)
  path
rescue StandardError => e
  warn "  ! image download failed (#{e.class}: #{e.message}) -- continuing without it"
  nil
end

def render_post(title:, time:, excerpt:, body:, image_url:, linkedin_url:, guid:)
  fm = {
    'layout'   => 'post',
    'title'    => title,
    'date'     => time.strftime('%Y-%m-%d %H:%M:%S %z'),
    'categories' => 'blog linkedin'
  }
  fm['excerpt'] = excerpt unless excerpt.to_s.empty?
  fm['image'] = image_url if image_url
  fm['linkedin_url'] = linkedin_url if linkedin_url
  fm['linkedin_guid'] = guid

  out = +"---\n"
  out << Psych.dump(fm, line_width: -1).sub(/\A---\n/, '')
  out << "---\n\n"
  out << "![](#{image_url})\n\n" if image_url
  out << body
  out << "\n"
  out << "\n*Originally posted [on LinkedIn](#{linkedin_url}).*\n" if linkedin_url
  out
end

def unique_path(dir, date_str, slug)
  base = File.join(dir, "#{date_str}-#{slug}")
  path = "#{base}.md"
  n = 2
  while File.exist?(path)
    path = "#{base}-#{n}.md"
    n += 1
  end
  path
end

# Build (and optionally write) the post for a feed item.
def import_item(item, dry_run: false)
  image_src = first_image_url(item.description) || item.media_url
  text  = html_to_text(item.description)
  title = derive_title(text)
  slug  = slugify(title)
  local = item.time.getlocal
  date_str = local.strftime('%Y-%m-%d')
  path  = unique_path(POSTS_DIR, date_str, slug)

  if dry_run
    puts "  would write #{rel(path)}"
    puts "    title: #{title}"
    puts "    image: #{image_src ? 'yes' : 'none'}"
    return nil
  end

  image_path = image_src ? download_image(image_src, "#{date_str}-#{slug}") : nil
  image_url  = image_path ? "#{IMAGE_URL}/#{File.basename(image_path)}" : nil

  FileUtils.mkdir_p(POSTS_DIR)
  File.write(path, render_post(
                     title: title, time: local, excerpt: derive_excerpt(text),
                     body: text, image_url: image_url,
                     linkedin_url: item.url, guid: item.guid
                   ))
  puts "  + #{rel(path)}"
  puts "    #{title}"

  {
    'activity' => item.activity,
    'url'      => item.url,
    'date'     => date_str,
    'title'    => title,
    'status'   => 'published',
    'post'     => rel(path),
    'image'    => image_path ? rel(image_path) : nil,
    'synced'   => Time.now.strftime('%Y-%m-%d')
  }.compact
end

# --------------------------------------------------------------------------
# helpers shared by commands
# --------------------------------------------------------------------------

# Fix up ledger `post:` paths and titles after renames/retitles, keying off the
# linkedin_guid in each post's front matter.
def heal_paths!(ledger)
  on_disk = scan_posts_by_guid
  healed = 0
  ledger['items'].each do |guid, entry|
    next unless entry['status'] == 'published'

    actual = on_disk[guid]
    next unless actual

    changed = false
    current = rel(actual)
    if entry['post'] != current
      entry['post'] = current
      changed = true
    end

    fm, = split_front_matter(File.read(actual))
    title = fm && fm['title']
    if title && !title.to_s.empty? && entry['title'] != title
      entry['title'] = title
      changed = true
    end

    healed += 1 if changed
  end
  healed
end

def resolve_ref(ledger, ref)
  needle = ref.to_s.downcase
  matches = ledger['items'].select do |guid, e|
    guid.start_with?(ref) ||
      e['activity'].to_s == ref ||
      e['title'].to_s.downcase.include?(needle) ||
      e['post'].to_s.downcase.include?(needle)
  end
  abort "No ledger entry matches '#{ref}'. Try `status` or `list`." if matches.empty?
  if matches.size > 1
    warn "'#{ref}' matches #{matches.size} entries:"
    matches.each { |g, e| warn "  #{g[0, 8]}  #{e['title']}" }
    abort 'Be more specific.'
  end
  matches.first
end

def delete_files(entry)
  [entry['post'], entry['image']].compact.each do |r|
    abs = File.join(ROOT, r)
    if File.exist?(abs)
      File.delete(abs)
      puts "  - #{r}"
    else
      puts "  (already gone: #{r})"
    end
  end
end

# --------------------------------------------------------------------------
# commands
# --------------------------------------------------------------------------

def cmd_list(opts)
  ledger = load_ledger
  heal_paths!(ledger)
  items = parse_feed(read_feed(feed_source(opts)))
  puts "#{items.size} item(s) in feed:"
  puts
  items.sort_by(&:time).reverse.each do |item|
    entry = ledger['items'][item.guid]
    state = if entry.nil?
              'NEW'
            else
              entry['status'] == 'excluded' ? 'excluded' : 'published'
            end
    title = entry&.dig('title') || derive_title(html_to_text(item.description))
    puts format('%-9s %-10s %-8s %s', item.guid[0, 8], item.time.getlocal.strftime('%Y-%m-%d'), state, title)
    puts "                              #{entry['post']}" if entry && entry['post'] && state == 'published'
  end
  puts
  new_count = items.count { |i| ledger['items'][i.guid].nil? }
  puts(new_count.zero? ? 'Nothing new. `sync` would do nothing.' : "#{new_count} new item(s). Run `sync` to import.")
end

def cmd_sync(opts)
  ledger = load_ledger
  healed = heal_paths!(ledger)
  puts "Healed #{healed} renamed post path(s)." if healed.positive?

  items = parse_feed(read_feed(feed_source(opts)))
  known_activity = ledger['items'].values.map { |e| e['activity'].to_s }.reject(&:empty?)

  new_items = items.reject do |item|
    ledger['items'].key?(item.guid) ||
      (item.activity && known_activity.include?(item.activity))
  end

  if new_items.empty?
    puts "No new LinkedIn posts (#{items.size} item(s) in feed, all known)."
    save_ledger(ledger) if healed.positive?
    return
  end

  puts "#{new_items.size} new item(s):"
  new_items.sort_by(&:time).each do |item|
    entry = import_item(item, dry_run: opts[:dry_run])
    ledger['items'][item.guid] = entry if entry
  end

  if opts[:dry_run]
    puts "\n(dry run -- nothing written)"
  else
    save_ledger(ledger)
    puts "\nWrote #{new_items.size} post(s) and updated #{rel(LEDGER_PATH)}."
  end
end

def cmd_status(_opts)
  ledger = load_ledger
  healed = heal_paths!(ledger)
  save_ledger(ledger) if healed.positive?

  on_disk = scan_posts_by_guid
  published = ledger['items'].select { |_g, e| e['status'] == 'published' }
  excluded  = ledger['items'].select { |_g, e| e['status'] == 'excluded' }

  puts "Ledger: #{ledger['items'].size} item(s) -- #{published.size} published, #{excluded.size} excluded."
  puts "Healed #{healed} renamed path(s)." if healed.positive?
  puts

  problems = 0
  published.each do |guid, e|
    next if on_disk.key?(guid)

    problems += 1
    if e['post'] && File.exist?(File.join(ROOT, e['post']))
      puts "! #{e['post']} exists but has no linkedin_guid in its front matter."
      puts "  Add `linkedin_guid: \"#{guid}\"` so renames keep tracking, or run `exclude #{guid[0, 8]}`."
    else
      puts "! Post file missing for: #{e['title']}"
      puts "  Ledger says #{e['post'] || '(none)'}. It will NOT be re-imported."
      puts "  Run `exclude #{guid[0, 8]}` to make that permanent, or `include #{guid[0, 8]}` to fetch it again."
    end
  end

  orphans = on_disk.reject { |guid, _| ledger['items'].key?(guid) }
  orphans.each do |guid, path|
    problems += 1
    puts "! #{rel(path)} has linkedin_guid #{guid[0, 8]} but no ledger entry."
    puts '  It will be re-imported as a duplicate on the next sync unless you add it to the ledger.'
  end

  puts 'Everything consistent.' if problems.zero?
end

def cmd_exclude(opts, ref)
  ledger = load_ledger
  heal_paths!(ledger)
  guid, entry = resolve_ref(ledger, ref)
  puts "Excluding: #{entry['title']}"
  delete_files(entry)
  entry['status'] = 'excluded'
  entry.delete('post')
  entry.delete('image')
  entry['synced'] = Time.now.strftime('%Y-%m-%d')
  save_ledger(ledger)
  puts "Struck from the blog. Sync will not bring it back."
  puts "(Undo with: ruby scripts/linkedin_sync.rb include #{guid[0, 8]})"
end

def cmd_include(opts, ref)
  ledger = load_ledger
  guid, entry = resolve_ref(ledger, ref)
  if entry['status'] == 'published' && entry['post'] && File.exist?(File.join(ROOT, entry['post']))
    abort "Already published at #{entry['post']}."
  end

  items = parse_feed(read_feed(feed_source(opts)))
  item = items.find { |i| i.guid == guid }
  abort "guid #{guid} is no longer in the feed, so it can't be re-imported." unless item

  puts "Re-importing: #{entry['title']}"
  new_entry = import_item(item)
  ledger['items'][guid] = new_entry
  save_ledger(ledger)
  puts 'Done.'
end

def cmd_refresh(opts, ref)
  ledger = load_ledger
  heal_paths!(ledger)
  guid, entry = resolve_ref(ledger, ref)
  abort "#{entry['title']} is excluded; use `include` instead." if entry['status'] == 'excluded'

  path = entry['post'] && File.join(ROOT, entry['post'])
  abort "No post file on disk for #{entry['title']}." unless path && File.exist?(path)

  items = parse_feed(read_feed(feed_source(opts)))
  item = items.find { |i| i.guid == guid }
  abort "guid #{guid} is no longer in the feed." unless item

  fm, = split_front_matter(File.read(path))
  fm ||= {}

  unless opts[:force]
    puts "This rewrites the body of #{entry['post']} from the feed."
    puts 'Your title, excerpt and image front matter are preserved; body edits are lost.'
    abort 'Aborted (no TTY; re-run with --force).' unless $stdin.tty?

    print 'Continue? [y/N] '
    abort 'Aborted.' unless $stdin.gets.to_s.strip.casecmp('y').zero?
  end

  text = html_to_text(item.description)
  File.write(path, render_post(
                     title: fm['title'] || derive_title(text),
                     time: item.time.getlocal,
                     excerpt: fm['excerpt'] || derive_excerpt(text),
                     body: text,
                     image_url: fm['image'],
                     linkedin_url: item.url,
                     guid: guid
                   ))
  entry['synced'] = Time.now.strftime('%Y-%m-%d')
  save_ledger(ledger)
  puts "Refreshed #{entry['post']}."
end

# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------

opts = { dry_run: false, force: false }
parser = OptionParser.new do |o|
  o.banner = 'Usage: ruby scripts/linkedin_sync.rb <list|sync|status|exclude|include|refresh> [options] [ref]'
  o.on('--feed SRC', 'RSS feed URL or a local .xml file') { |v| opts[:feed] = v }
  o.on('--dry-run', 'sync only: show what would happen, write nothing') { opts[:dry_run] = true }
  o.on('--force', 'refresh only: skip the confirmation prompt') { opts[:force] = true }
  o.on('-h', '--help') do
    puts o
    exit 0
  end
end
args = parser.parse(ARGV)
apply_site_timezone!

command = args.shift
ref = args.shift

case command
when 'list'    then cmd_list(opts)
when 'sync'    then cmd_sync(opts)
when 'status'  then cmd_status(opts)
when 'exclude' then ref ? cmd_exclude(opts, ref) : abort('exclude needs a <ref>')
when 'include' then ref ? cmd_include(opts, ref) : abort('include needs a <ref>')
when 'refresh' then ref ? cmd_refresh(opts, ref) : abort('refresh needs a <ref>')
when nil       then abort(parser.to_s)
else abort("Unknown command '#{command}'.\n\n#{parser}")
end
