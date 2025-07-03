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
          # get params
          options = argv.select { _1.start_with?('--') }
          port = options.find { _1.start_with?('--port') }&.split('=')&.last
          jit = options.find { _1.start_with?('--jit') }&.split('=')&.last

          port ||= '7000'
          print_logo
          color_puts("Starting takeoff of ruBee server on port #{port}...", color: :yellow)
          command = "#{jit_prefix(jit)}rackup #{ENV['RACKUP_FILE']} -p #{port}"
          color_puts(command, color: :gray)
          exec(command)
        end

        def start_dev(argv)
          options = argv.select { _1.start_with?('--') }
          port = options.find { _1.start_with?('--port') }&.split('=')&.last
          jit = options.find { _1.start_with?('--jit') }&.split('=')&.last

          port ||= '7000'
          print_logo

          color_puts("Starting takeoff of ruBee server on port #{port} in dev mode...", color: :yellow)
          command = "rerun -- #{jit_prefix_dev(jit)}rackup --port #{port} #{ENV['RACKUP_FILE']}"
          color_puts(command, color: :gray)
          exec(command)
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

        def jit_prefix(key)
          case key
          when 'yjit'
            "ruby --yjit -S "
          else
            ""
          end
        end

        def jit_prefix_dev(key)
          case key
          when 'yjit'
            "ruby --yjit -S "
          else
            ""
          end
        end
      end
    end
  end
end
