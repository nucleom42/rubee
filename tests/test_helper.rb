require_relative File.join(__dir__, '..', 'rubee')

require "bundler/setup"
Bundler.require(:test)

require 'minitest/autorun'
require 'rack/test'

Rubee::Autoload.call

