require_relative File.join(File.expand_path(Dir.pwd), 'lib', 'rubee.rb')

require "bundler/setup"
Bundler.require(:test)

require 'minitest/autorun'
require 'rack/test'

Rubee::Autoload.call


