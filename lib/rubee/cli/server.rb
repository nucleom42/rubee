module Rubee
  module CLI
    class Server
      LOGO = <<-'LOGO'
  ____  _    _  ____  _____
 |  _ \| |  | || __ )| ____|
 | |_) | |  | ||  _ \|  _|
 |  _ <| |__| || |_) | |___
 |_| \_\\____/ |____/|_____|
 Ver: %s
LOGO

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

        def print_logo
          puts "\e[36m#{LOGO % Rubee::VERSION}\e[0m" # Cyan color
        end
      end
    end
  end
end
