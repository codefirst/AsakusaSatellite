source 'https://rubygems.org'
ruby ENV['CUSTOM_RUBY_VERSION'] || '2.6.5'

gem 'rails', '6.0.0'

# mongoid
gem 'mongoid', '7.0.5'

# push notification
gem 'eventmachine'
gem 'pusher'
gem 'socky-client', '>= 0.5.0.beta1'

# html
gem 'haml-rails'
gem 'sass-rails'
gem "execjs"
gem 'therubyracer'
gem 'uglifier'

# util
gem 'rest-client'
gem 'on_the_spot'
gem "uuidtools"
gem 'omniauth'
gem 'json'

# socky
gem 'socky-server', '>= 0.5.0.beta1'
gem 'thin'

group :development do
  gem 'listen'
end

group :development, :test do
  gem 'test-unit'
  gem 'rails-controller-testing'
  gem "rspec-rails", '>= 4.0.0.beta2'
  gem "rspec-its"
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
end

Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', "Gemfile")) do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end
