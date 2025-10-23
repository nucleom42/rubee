module Rubee
  module CLI
    module Console
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def console(argv)
          argv.clear
          ENV['RACK_ENV'] ||= 'development'

          if Rubee::PROJECT_NAME == 'rubee'
            Rubee::Configuration.setup(env = :test) do |config|
              config.database_url = { url: 'sqlite://lib/tests/test.db', env: }
            end
          end

          def reload
            app_files = Dir["./#{Rubee::APP_ROOT}/**/*.rb"]
            app_files.each { |file| load(file) }
            color_puts('Reloaded ..', color: :green)
          end

          begin
            # Start IRB
            IRB.start
          rescue => _e
            IRB.start
          end
        end

        alias_method :c, :console
      end
    end
  end
end
