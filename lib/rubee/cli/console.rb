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
