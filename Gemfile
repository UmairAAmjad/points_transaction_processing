# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'
gem 'bootsnap', require: false
gem 'httparty'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.3', '>= 7.1.3.4'
gem 'rubocop', require: false
gem 'rubocop-rails', require: false
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :development do
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
end
