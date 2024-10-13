source 'https://rubygems.org'

# Basic
gem 'bootsnap', require: false
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.2.0'
gem 'tzinfo-data', platforms: %i[windows jruby]

# API
gem 'rack-cors'

# Security
# ...

# Performance
# ...

group :test do
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
  gem 'rubocop-rails', require: false
  gem 'rubocop-rails-omakase', require: false
end
