require 'irb'
require_relative 'mini_rails.rb'

MiniRails::Autoload.call

def reload
  app_files = Dir["./app/**/*.rb"]
  app_files.each { |file| load file }
  puts "Reloaded!!!"
end

# Start IRB
IRB.start
