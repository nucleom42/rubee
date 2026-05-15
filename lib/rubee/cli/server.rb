module Rubee
  module CLI
    class Server
      LOGO = <<-'LOGO'
  ____  _    _  ____  _____
 |  _ \| |  | || __ )| ____|_
 | |_) | |  | ||  _ \|  _|  _|
 |  _ <| |__| || |_) | |___ _
 |_| \_\\____/ |____/|_____|__|
 Ver: %s       ⬡ ⬢ ⬢ rubee ⬢ ⬡
LOGO
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def start(argv)
          options    = argv.select { _1.start_with?('--') }
          port       = options.find { _1.start_with?('--port') }&.split('=')&.last
          jit        = options.find { _1.start_with?('--jit') }&.split('=')&.last
          port     ||= ENV.fetch('PORT', '7000')  # fix: don't clobber parsed port
          puma_config = ENV.fetch('PUMA_CONFIG', 'config/puma.rb')
          rackup_file = ENV.fetch('RACKUP_FILE', '')

          print_logo
          color_puts("Starting takeoff of ruBee on port: #{port}...", color: :yellow)

          command = [
            jit_prefix(jit),
            "bundle exec puma",
            File.exist?(puma_config) ? "-C #{puma_config}" : '',
            rackup_file,
            "-p #{port}",
          ].join(" ")

          color_puts(command, color: :gray)
          exec(command)
        end

        def start_dev(argv)
          options = argv.select { _1.start_with?('--') }
          port    = options.find { _1.start_with?('--port') }&.split('=')&.last
          jit     = options.find { _1.start_with?('--jit') }&.split('=')&.last
          port  ||= ENV.fetch('PORT', '7000')  # fix: consistent with start; use ENV fallback
          rackup_file = ENV.fetch('RACKUP_FILE', '')

          print_logo
          color_puts("Starting takeoff of ruBee server on port #{port} in dev mode...", color: :yellow)

          command = "rerun -- #{jit_prefix(jit)}rackup --port #{port} #{rackup_file}"
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
          puts "\e[36m#{LOGO % Rubee::VERSION}\e[0m"
        end

        def jit_prefix(key)  # fix: removed identical jit_prefix_dev; use this for both
          case key
          when 'yjit' then "ruby --yjit -S "
          else ""
          end
        end
      end
    end
  end
end
