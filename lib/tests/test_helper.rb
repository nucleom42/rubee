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

Rubee::CLI::Db.call('db', ['db', 'init']) # ensure test db exists
Rubee::SequelObject.reconnect! # connect to test db

def truncate_test_tables!
  db = Rubee::SequelObject::DB
  if db.adapter_scheme == :sqlite
    # Disable FK checks for SQLite
    db.run('PRAGMA foreign_keys = OFF')
    
    tables_to_truncate.each do |table|
      db[table].delete
    end
    
    db.run('PRAGMA foreign_keys = ON')
  else
    # For PostgreSQL/MySQL, disable triggers if needed
    tables_to_truncate.each do |table|
      db[table].delete
    end
  end
end

def tables_to_truncate
  db = Rubee::SequelObject::DB
  db.tables.reject { |t| t.to_s.start_with?('sqlite_') }
end

# delete all tables from test db
truncate_test_tables!

# run migrations in test db
Rubee::CLI::Db.call('db', ['db', 'run:all']) 

# Load test seed data
require_relative 'test_seed'
TestSeed.load

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
