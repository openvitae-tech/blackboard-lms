# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '7.2.1.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 6.4.3'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

gem 'devise', '~> 4.9.2'

# gem 'vimeo_me2', :git => "https://github.com/bo-oz/vimeo_me2.git"
gem 'rubocop', require: false
gem 'rubocop-discourse', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'database_cleaner'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'guard-rspec', require: false
  gem 'rails-controller-testing'
  gem 'rspec-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'letter_opener'
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webmock'
end

gem 'pundit', '~> 2.3'

gem 'tailwindcss-rails', '~> 2.6.5'

gem 'kaminari'

gem 'aws-sdk-s3', require: false
gem 'chartkick'
gem 'groupdate'

gem 'rexml', '>= 3.3.9'
gem 'webrick', '>= 1.8.2'

gem 'sentry-rails'
gem 'sentry-ruby'
gem 'stackprof'

# Background jobs
gem 'sidekiq'

# For periodic jobs on sidekiq
gem 'sidekiq-cron'

# For seeing failed jobs in sidekiq
gem 'sidekiq-failures'

# adds unique constraints to sidekiq jobs
gem 'sidekiq-unique-jobs'
