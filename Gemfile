source 'http://rubygems.org'

gem 'rails', '3.1.1'

# mongoid
gem 'mongoid', '2.3.0'
gem 'bson_ext'

gem "rails3-generators"

group :development, :test do
  gem "rspec-rails", ">= 2.3.0"
  gem 'rcov'
  gem 'nokogiri'
  gem 'ci_reporter'
  gem 'spork'
  gem 'rb-fsevent'
  gem 'guard-spork'
  gem 'guard-rspec'
end

#gem 'SystemTimer'
gem 'pusher'
gem 'socky-client', '>= 0.5.0.beta1'
gem 'socky-server', '>= 0.5.0.beta1'
gem 'thin'
gem 'c2dm'

# html
gem "uuidtools"
gem 'hassle', :git => 'git://github.com/koppen/hassle.git'
gem 'coderay'
gem 'haml-rails'
gem 'sass'
gem 'jquery-rails'
gem 'oauth'
gem 'json', "= 1.5.3"
gem "on_the_spot"

# push notification
gem 'apns'

gem "uuidtools"
gem 'coderay'
gem 'pusher'
gem 'hassle', :git => 'git://github.com/koppen/hassle.git'
gem 'rest-client'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

Dir.glob(File.join(File.dirname(__FILE__), 'vendor', 'plugins', '**', "Gemfile")) do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end
