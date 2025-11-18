def reload
  app_files = Dir["./#{Rubee::APP_ROOT}/**/*.rb"]
  app_files.each { |file| load(file) }
  puts "\e[32mReloaded..\e[0m"
end


