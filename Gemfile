# frozen_string_literal: true

source 'https://rubygems.org'

# Basic
gem 'bootsnap', require: false
gem 'pg', '~> 1.5'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.2.1'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'sprockets-rails', require: 'sprockets/railtie'

# API
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger', '>= 2.0.1'
gem 'grape-swagger-entity'
gem 'grape-swagger-rails'
gem 'rack-cors'

# Utils
gem 'httparty', require: false
gem 'mime-types', require: false

# Security
gem 'jwt'
gem 'pundit'

# Performance
# ...

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :development, :test do
  gem 'brakeman', require: false

  gem 'dotenv-rails'

  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rails-omakase', require: false
end
