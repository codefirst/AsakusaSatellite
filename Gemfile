source 'https://rubygems.org'
ruby ENV['CUSTOM_RUBY_VERSION'] || '2.5.7'

gem 'rails', '5.2.3'
gem 'bootsnap', require: false

# mongoid
gem 'mongoid', '6.4.4'

# push notification
gem 'eventmachine'
gem 'pusher'
gem 'socky-client', '>= 0.5.0.beta1'

# html
gem 'haml-rails'
gem 'sass-rails', '5.0.6'
gem 'compass-rails', '3.1.0'
gem "execjs"
gem 'therubyracer', :platform => :ruby
gem 'uglifier', '~> 2.7'

# util
gem 'rest-client'
gem 'on_the_spot'
gem "uuidtools"
gem 'omniauth'
gem 'json'

group :development do
  gem 'listen'
end

group :development, :test do
  gem 'test-unit', '~> 3.0'
  gem 'rails-controller-testing'
  gem "rspec-rails"
  gem "rspec-its"
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
end

platform :ruby, :mswin, :mingw do
  gem 'socky-server', '>= 0.5.0.beta1'
  gem 'thin'
end

platform :jruby do
  gem 'warbler'

  # FIXME: warbler does not recognize plugins' Gemfile
  gem 'omniauth-twitter', '>= 0.0.14'
end

Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end
