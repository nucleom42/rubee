module Rubee
  module CLI
    module Console
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def console(argv)
          argv.clear
          # ENV['RACK_ENV'] ||= 'development' # already set in bin/rubee

          # if Rubee::PROJECT_NAME == 'rubee'
          #   Rubee::Configuration.setup(env = :test) do |config|
          #     config.database_url = { url: 'sqlite://lib/tests/test.db', env: }
          #   end
          # end

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
