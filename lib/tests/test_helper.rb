require "bundler/setup"
Bundler.require(:test)

require 'minitest/autorun'
require 'rack/test'
require_relative '../../lib/rubee'

Rubee::Autoload.call


