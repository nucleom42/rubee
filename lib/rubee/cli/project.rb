module Rubee
  module CLI
    class Project
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def project(argv)
          project_name = argv[1]

          if project_name.nil?
            color_puts('Please indicate project name.', color: :red)
            exit(1)
          end

          if project_name == 'rubee'
            color_puts("Error: Project 'rubee' is reserved", color: :red)
            exit(1)
          end
          source_dir = File.join(Rubee::ROOT_PATH, '/lib')
          target_dir = File.expand_path("./#{project_name}", Dir.pwd)

          if Dir.exist?(target_dir)
            color_puts("Error: Project #{project_name} already exists!", color: :red)
            exit(1)
          end
          # Create target directory
          FileUtils.mkdir_p(target_dir)
          # Define blacklist
          blacklist_files = %w[rubee.rb print_colors.rb version.rb config.ru test_helper.rb Gemfile.lock test.yml test.db
                               test_seed.rb development.db production.db users_controller.rb users_controller.rb]
          blacklist_dirs = %w[rubee tests .git .github .idea node_modules db inits]
          # Copy files, excluding blacklisted ones
          copy_project_files(source_dir, target_dir, blacklist_files, blacklist_dirs)
          # create tests dir and copy test_helper.rb and user_model_test.rb
          setup_test_structure(target_dir, source_dir)
          # create db dir
          setup_db_structure(target_dir, source_dir)
          # create inits dir
          FileUtils.mkdir_p("#{target_dir}/inits")
          # create a gemfile context
          setup_gemfile(target_dir)
          color_puts("Project #{project_name} created successfully at #{target_dir}", color: :green)
        end

        private

        def copy_project_files(source_dir, target_dir, blacklist_files, blacklist_dirs)
          Dir.glob("#{source_dir}/**/*", File::FNM_DOTMATCH).each do |file|
            relative_path = file.sub("#{source_dir}/", '')
            # Skip blacklisted directories
            next if blacklist_dirs.any? { |dir| relative_path.split('/').include?(dir) }
            # Skip blacklisted files
            next if blacklist_files.include?(File.basename(file))

            target_path = File.join(target_dir, relative_path)
            if File.directory?(file)
              FileUtils.mkdir_p(target_path)
            else
              FileUtils.cp(file, target_path)
            end
          end
        end

        def setup_test_structure(target_dir, source_dir)
          FileUtils.mkdir_p("#{target_dir}/tests")
          FileUtils.mkdir_p("#{target_dir}/tests/models")
          FileUtils.mkdir_p("#{target_dir}/tests/controllers")
          FileUtils.cp("#{source_dir}/tests/models/user_model_test.rb", "#{target_dir}/tests/models/user_model_test.rb")

          # create test_helper.rb file
          test_helper = <<~TESTHELPER
            require "bundler/setup"
            Bundler.require(:test)

            require 'minitest/autorun'
            require 'rack/test'
            require 'rubee'

            Rubee::Autoload.call
          TESTHELPER

          File.open("#{target_dir}/tests/test_helper.rb", 'w') do |file|
            file.puts test_helper
          end
        end

        def setup_db_structure(target_dir, source_dir)
          FileUtils.mkdir_p("#{target_dir}/db")
          FileUtils.cp("#{source_dir}/db/structure.rb", "#{target_dir}/db/structure.rb")
          FileUtils.cp("#{source_dir}/db/create_users.rb", "#{target_dir}/db/create_users.rb")
        end

        def setup_gemfile(target_dir)
          gemfile = <<~GEMFILE
            source 'https://rubygems.org'

            gem 'ru.Bee'
            gem 'dotenv'
            gem 'sequel'
            gem 'sqlite3'
            gem 'rake'
            gem 'rack'
            gem 'rackup'
            gem 'pry'
            gem 'pry-byebug'
            gem 'puma'
            gem 'json'
            gem 'jwt'

            # Websocket is required to use integrated websocket feature
            gem 'websocket'
            # Redis is required for pubsub and websocket
            gem 'redis'

            group :development do
              gem 'rerun'
              gem 'minitest'
              gem 'rack-test'
            end
          GEMFILE
          # create a gemfile
          File.open("#{target_dir}/Gemfile", 'w') do |file|
            file.puts gemfile
          end
        end
      end
    end
  end
end
