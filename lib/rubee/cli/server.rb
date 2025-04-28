module Rubee
  module CLI
    class Server
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def start(argv)
          _, port = argv.first&.split(':')

          port ||= '7000'
          print_logo
          color_puts("Starting takeoff of ruBee server on port #{port}...", color: :yellow)
          exec("rackup #{ENV['RACKUP_FILE']} -p #{port}")
        end

        def start_dev(argv)
          _, port = argv.first&.split(':')

          port ||= '7000'
          print_logo

          color_puts("Starting takeoff of ruBee server on port #{port} in dev mode...", color: :yellow)

          exec("rerun -- rackup --port #{port} #{ENV['RACKUP_FILE']}")
        end

        def stop(_argv)
          exec('pkill -f rubee')
        end

        def status(_argv)
          exec('ps aux | grep rubee')
        end
      end
    end
  end
end
