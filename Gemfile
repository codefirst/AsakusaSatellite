source 'http://rubygems.org'

gem 'rails', '3.2.8'

# mongoid
gem 'mongoid', '2.3.0'
gem 'bson_ext'

# push notification
gem 'pusher'
gem 'socky-client', '>= 0.5.0.beta1'
gem 'socky-server', '>= 0.5.0.beta1'
gem 'thin'

# html
gem 'haml-rails'
gem 'sass-rails'
gem "execjs"
gem "therubyracer", :platform => :ruby
gem 'uglifier', '>= 1.0.3'

# util
gem 'rest-client'
gem 'on_the_spot'
gem "uuidtools"
gem 'omniauth'
gem 'json', "= 1.5.3"
gem 'newrelic_rpm'

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

Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end
