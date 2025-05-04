module Rubee
  module CLI
    class Attach
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def attach(argv)
          new_app_name = argv[1]

          # create project folde
          if new_app_name.nil?
            color_puts('Please indicate app name.', color: :red)
            exit(1)
          end

          if new_app_name == 'rubee'
            color_puts("Error: App 'rubee' name is reserved", color: :red)
            exit(1)
          end
          target_dir = File.join(Rubee::APP_ROOT, new_app_name)

          if Dir.exist?(target_dir)
            color_puts("Error: App #{new_app_name} already exists!", color: :red)
            exit(1)
          end

          # create controllers models view folders
          FileUtils.mkdir_p(target_dir)
          # creare controllers models views dirs
          ['controllers', 'models', 'views'].each do |dir|
            FileUtils.mkdir_p("#{target_dir}/#{dir}")
          end

          config_file = <<~CONFIG_FILE
            Rubee::Configuration.setup(env = :test, app = :#{new_app_name}) do |config|
            end
            Rubee::Configuration.setup(env = :developmenti, app = :#{new_app_name}) do |config|
            end
            Rubee::Configuration.setup(env = :production, app = :#{new_app_name}) do |config|
            end
          CONFIG_FILE

          File.open("#{target_dir}/#{new_app_name}_configuration.rb", 'w') do |file|
            file.puts config_file
          end

          # create app routes.rb file
          route_file = <<~ROUTE_FILE
            Rubee::Router.draw do |router|
            end
          ROUTE_FILE

          File.open("#{target_dir}/#{new_app_name}_routes.rb", 'w') do |file|
            file.puts route_file
          end
        end
      end
    end
  end
end
