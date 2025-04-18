require 'bundler/setup'
Bundler.require(:test)

require 'simplecov'
SimpleCov.start do
  add_filter %r{^/lib/db/}
  add_filter %r{^/lib/inits/}
  add_filter %r{^/lib/tests/}
end

require 'minitest/autorun'
require 'rack/test'
require_relative '../../lib/rubee'

Rubee::Autoload.call
Rubee::Configuration.setup(env = :test) do |config|
  config.database_url = { url: 'sqlite://lib/tests/test.db', env: }
end
Rubee::SequelObject.reconnect!
