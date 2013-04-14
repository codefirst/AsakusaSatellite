require 'rubygems'
require 'spork'
require 'rspec/autorun'

Spork.prefork do
  if (not ENV['DRB']) and RUBY_VERSION >= '1.9'
    begin
      require 'simplecov'
      SimpleCov.start 'rails' do
        add_filter '.bundle'
      end
    rescue LoadError
    end
  end

  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
#    config.fixture_path = "#{::Rails.root}/spec/fixtures"
#    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  silence_warnings do
    Dir[Rails.root.join('app/**/*.rb')].each do |file|
      load file
    end
  end
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading
#   code that you don't normally modify during development in the
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




# see also http://blog.s21g.com/articles/1932
$LOADED_FEATURES.push File.expand_path(__FILE__)
def require(path)
  path = File.expand_path(path) if path =~ %r{^[./]}
  super path
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true
end

def cleanup_db
  User.all.each{|u| u.delete }
  Message.all.each{|m| m.delete }
  Room.all.each{|r| r.delete }
end
