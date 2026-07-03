def reload
  app_files = Dir["./#{Rubee::APP_ROOT}/**/*.rb"]
  app_files.each { |file| load(file) }
  puts "\e[32mReloaded..\e[0m"
end

def load_envs!(prefix = ENV['RACK_ENV'])
  env_file_name = "#{Rubee::APP_ROOT}/.#{prefix}.env"
  File.foreach(env_file_name) do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    key, value = line.split('=', 2)
    ENV[key] = value
  end
end
