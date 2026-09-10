---
layout: page
title: Dev help for this blog
tags: dev
---

## Local development setup

Ruby is pinned to 3.3 by `mise.toml` in the repo root -- the same version the
deploy workflow uses. [mise](https://mise.jdx.dev) is already installed and its
shims are on `PATH`, so `cd`ing into this repo gives you the right Ruby
automatically:

    mise install          # first time on a new machine; installs Ruby 3.3
    ruby -v               # => ruby 3.3.x
    bundle install        # gems go into vendor/bundle (gitignored)

Do *not* use Arch's system Ruby for this site. It's 3.4, which unbundled `csv`,
`base64` and `mutex_m`, and this Gemfile pins Jekyll 3.10 with the old `sass`
3.7.4 -- that combination is not worth fighting.

If `bundle exec jekyll` ever fails with `env: 'ruby3.3': No such file or
directory`, the binstubs in `vendor/bundle` are stale from an older setup:

    rm -rf vendor/bundle && bundle install


## Run locally

Serve with drafts on port 4001:

    bundle exec jekyll serve --drafts --port 4001

Build once (no server):

    bundle exec jekyll build


## Deployment

Pushing to `master` automatically triggers a GitHub Actions workflow
(`.github/workflows/deploy.yml`) that builds the site with Ruby 3.3
and deploys it to GitHub Pages.

To trigger a build manually without a commit: go to the repo on GitHub →
**Actions** → **Deploy Jekyll site to Pages** → **Run workflow**.

Build output and errors are visible in the Actions tab on GitHub.

**One-time repo setting** (already done): GitHub repo → Settings → Pages →
Source must be set to **"GitHub Actions"** (not "Deploy from a branch").


## Updating gems

To pull in the latest github-pages-compatible gem versions:

    bundle update github-pages
    git add Gemfile.lock
    git commit -m "Update gems"
    git push

The next deployment will automatically use the updated gems.


## Analytics

Google Analytics 4 property ID is `G-LGV2MK3NJP` (set in `_config.yml`).
Analytics only fires when `JEKYLL_ENV=production`, which the deploy workflow
sets automatically. It does **not** fire during local `jekyll serve`.


## LinkedIn sync

Posts from LinkedIn are pulled in daily by the `Sync LinkedIn Posts` GitHub Action.
To check for new ones and tailor them by hand before that runs:

    ruby scripts/linkedin_sync.rb list
    ruby scripts/linkedin_sync.rb sync --dry-run
    ruby scripts/linkedin_sync.rb sync

To strike one from the blog for good:

    ruby scripts/linkedin_sync.rb exclude <title-substring>

Full details, including how editing and deleting interact with the daily Action,
are in [README-LinkedIn.md](https://github.com/shimon/shimon.github.io/blob/master/README-LinkedIn.md).


## Useful links

* [Jekyll Docs - Templates](https://jekyllrb.com/docs/templates/)
* [Liquid templating engine](http://shopify.github.io/liquid/)
* [Kramdown quick reference](https://kramdown.gettalong.org/quickref.html)
* [GitHub Actions workflow syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
