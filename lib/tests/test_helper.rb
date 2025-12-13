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
require 'stringio'

require_relative '../../lib/rubee'

Rubee::Autoload.call

def assert_difference(expression, difference = 1)
  before = expression.call
  yield
  after = expression.call
  actual_diff = after - before

  assert_equal(difference, actual_diff,
    "Expected change of #{difference}, but got #{actual_diff}")
end

def capture_stdout
  old_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = old_stdout
end

def raise_error
  yield
rescue => e
  e
end

