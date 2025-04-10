require 'bundler/setup'
Bundler.require(:test)

require 'minitest/autorun'
require 'rack/test'
require_relative '../../lib/rubee'

require 'simplecov'
SimpleCov.start

Rubee::Autoload.call
Rubee::Configuration.setup(env = :test) do |config|
  config.database_url = { url: 'sqlite://lib/tests/test.db', env: }
end
Rubee::SequelObject.reconnect!
