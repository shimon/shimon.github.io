source "https://rubygems.org"

# Jekyll proper, not the github-pages gem. This site is built by our own
# GitHub Actions workflow (.github/workflows/deploy.yml) and uploaded as a
# Pages artifact, so we never touch GitHub's legacy Pages builder that the
# github-pages gem exists to mirror -- and we're not held back to Jekyll 3.
gem "jekyll", "~> 4.4"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  gem "minima", "~> 2.5"
end
