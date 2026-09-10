# LinkedIn → blog sync

Posts you write on LinkedIn are pulled into this Jekyll blog as regular posts in
`_posts/`, tagged `categories: blog linkedin` so they show up in the main list on
`/` and `/blog`.

There are two ways this happens:

* **Automatically**, once a day, via the `Sync LinkedIn Posts` GitHub Action.
  You don't have to do anything.
* **Manually**, from a checkout, when you want to look at something and tailor it
  before it goes live.

Both use the same script: `scripts/linkedin_sync.rb`.

---

## How duplicates and edits are handled

Every item in the RSS feed has a stable `<guid>`. Each one this blog has ever seen
is recorded in **`_data/linkedin.yml`**, along with what you decided to do with it.

**An item recorded in the ledger is never imported again** — regardless of its
status, and regardless of what happened to the generated file. That single rule is
what makes the following safe:

| You do this | Next sync does |
|---|---|
| Edit the title, body, or excerpt | nothing — your version stands |
| Rename the file | nothing; the ledger's path is quietly corrected |
| Move it to `_drafts/` | nothing; it stays unpublished |
| `rm` the file | nothing; it is *not* recreated (`status` will flag it) |
| `exclude` it | nothing; it's tombstoned for good |

The link between a post and its ledger entry is the `linkedin_guid` field in the
post's front matter. Keep that line and you can change everything else.

---

## Setup

### One time, on GitHub (already done)

Repo → **Settings** → **Secrets and variables** → **Actions** → new repository
secret named `LINKEDIN_RSS_URL`, set to the rss.app feed URL for your LinkedIn
profile. The feed itself is generated at [rss.app](https://rss.app) from
`https://www.linkedin.com/in/shimonrura/`.

### One time, on a dev machine

Ruby 3.3 is pinned by `mise.toml`, matching the deploy workflow; `mise install`
sets it up and `rexml` comes with it. See `devhelp.md` for the details.

Give the script the feed URL once, so you don't have to pass `--feed` every
time. This file is gitignored:

```bash
echo 'https://rss.app/feeds/XXXXXXXX.xml' > .linkedin-rss-url
```

(`--feed <url>` and `$LINKEDIN_RSS_URL` also work, and take precedence in that
order.)

---

## Working locally

```bash
# What's in the feed, and what has the blog already done with it?
ruby scripts/linkedin_sync.rb list

# Import anything new. Add --dry-run first to see it without writing.
ruby scripts/linkedin_sync.rb sync --dry-run
ruby scripts/linkedin_sync.rb sync

# Sanity check the ledger against what's actually on disk
ruby scripts/linkedin_sync.rb status
```

A typical session: `list` to see what's landed, `sync` to bring it in, open the
new file in `_posts/`, edit the title and excerpt to suit the blog, then commit.

### Editing a post

Just edit the file. The fields worth touching:

```yaml
title:    # shown in the post and in the blog list
excerpt:  # the blurb in the blog list at / and /blog — this is the "description"
image:    # /images/blog/linkedin/... — delete the line and the ![]() to drop it
```

`excerpt` is set explicitly because these posts open with an image; without it,
Jekyll's auto-excerpt would make the blog list lead with a picture instead of
words.

To hold a post back without deleting it, move it to `_drafts/` — sync leaves it
alone, and `bundle exec jekyll serve --drafts` still previews it.

### Striking a post from the blog

```bash
ruby scripts/linkedin_sync.rb exclude dogs
```

`<ref>` can be a guid prefix, a LinkedIn activity id, or any substring of the
title or filename — so `exclude dogs` works if that word is in the title. This
deletes the post file and its downloaded image, and marks the item `excluded` in
the ledger so no future sync brings it back.

Changed your mind:

```bash
ruby scripts/linkedin_sync.rb include dogs
```

That re-imports it from the feed, as long as the item is still in the feed (rss.app
keeps only the most recent items).

### Re-pulling the text from LinkedIn

If you edited the post on LinkedIn after it was imported:

```bash
ruby scripts/linkedin_sync.rb refresh dogs
```

Your `title`, `excerpt` and `image` front matter survive; the body is replaced with
the feed's current text. It asks first.

---

## The daily Action

`.github/workflows/sync-linkedin.yml` runs at 06:00 UTC and on demand
(**Actions** → **Sync LinkedIn Posts** → **Run workflow**). It runs
`linkedin_sync.rb sync` and commits `_posts/`, `_data/linkedin.yml`, and
`images/blog/linkedin/` — all three, since the ledger and images are what keep the
next run from re-importing everything. The push then triggers the normal Pages
deploy.

**Local work and the Action don't fight.** The Action only ever adds guids the
ledger has never seen. Once you've pushed your edits and exclusions, it respects
them. The one thing to remember: if you sync locally, **commit
`_data/linkedin.yml` along with the posts** — otherwise the Action's ledger won't
know about the items you imported, and it will import them a second time.

---

## What a generated post looks like

```markdown
---
layout: post
title: After 7.5 years at Verily, I'm taking a sabbatical
date: '2026-08-07 00:37:05 +0000'
categories: blog linkedin
excerpt: After 7.5 years at Verily, I'm taking a sabbatical. Like prior breaks…
image: "/images/blog/linkedin/2026-08-07-after-7-5-years-at-verily-im-taking-a-sabbatical.jpg"
linkedin_url: https://www.linkedin.com/posts/shimonrura_after-75-years-…
linkedin_guid: bf9349da26d1f9ede0daab453ee45044
---

![](/images/blog/linkedin/2026-08-07-after-7-5-years-at-verily-im-taking-a-sabbatical.jpg)

After 7.5 years at Verily, I'm taking a sabbatical. …

*Originally posted [on LinkedIn](https://www.linkedin.com/posts/…).*
```

The title is the first sentence of the post (used whole up to 100 characters,
otherwise truncated at a word boundary). LinkedIn's HTML is converted to text:
entities decoded, `<br>` turned into hard line breaks so the original line
structure survives, attached images downloaded into `images/blog/linkedin/`.
