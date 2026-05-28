---
layout: page
title: Dev help for this blog
tags: dev
---

## Local development setup (Ubuntu)

Install Ruby and build tools if you haven't already:

    sudo apt update
    sudo apt install -y ruby-full build-essential zlib1g-dev
    gem install bundler --user-install

Add gems to your PATH (add to `~/.bashrc` then `source ~/.bashrc`):

    export GEM_HOME="$HOME/.gems"
    export PATH="$HOME/.gems/bin:$HOME/bin:$PATH"

The `gem install bundler` command may create the binary as `bundle3.3` instead of
`bundle`. If so, symlink it:

    ln -s $(which bundle3.3) ~/.gems/bin/bundle

Then install this site's gems (from the repo root):

    bundle install


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


## Useful links

* [Jekyll Docs - Templates](https://jekyllrb.com/docs/templates/)
* [Liquid templating engine](http://shopify.github.io/liquid/)
* [Kramdown quick reference](https://kramdown.gettalong.org/quickref.html)
* [GitHub Actions workflow syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
