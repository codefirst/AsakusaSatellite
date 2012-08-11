source 'http://rubygems.org'

gem 'rails', '3.1.1'

# mongoid
gem 'mongoid', '2.3.0'
gem 'bson_ext'

# push notification
gem 'pusher'
gem 'socky-client', '>= 0.5.0.beta1'
gem 'socky-server', '>= 0.5.0.beta1'
gem 'thin'

# html
gem "uuidtools"
gem 'haml-rails'
gem 'sass'
gem 'jquery-rails'
gem 'oauth'
gem 'json', "= 1.5.3"
gem 'on_the_spot'

# for heroku
gem 'hassle', :git => 'git://github.com/koppen/hassle.git'

group :development, :test do
  gem "rails3-generators"
  gem "rspec-rails", ">= 2.3.0"
  gem 'rcov', :platforms => :ruby_18
  gem 'ci_reporter'
  gem 'spork'
  gem 'rb-fsevent'
  gem 'guard-spork'
  gem 'guard-rspec'
end

Dir.glob(File.join(File.dirname(__FILE__), 'vendor', 'plugins', '**', "Gemfile")) do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end
