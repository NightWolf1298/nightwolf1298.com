source "https://rubygems.org"

gem "jekyll", "~> 4.3"
# gem "github-pages", group: :jekyll_plugins

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
end

install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 2.0"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :install_if => Gem.win_platform?
