module Rubee
  module CLI
    class Command
      def initialize(argv)
        @command = argv[0]
        @argv = argv
      end

      def call
        factory.call(@command, @argv)
      end

      def factory
        case @command
        in /start|start_dev|stop|status/
          Rubee::CLI::Server
        in /react/
          Rubee::CLI::React
        in /project/
          Rubee::CLI::Project
        in /version/
          Rubee::CLI::Version
        in /routes/
          Rubee::CLI::Routes
        in /test/
          Rubee::CLI::Test
        in /generate|gen/
          Rubee::CLI::Generate
        in /db/
          Rubee::CLI::Db
        in /console|con/
          Rubee::CLI::Console
        in /attach|att/
          Rubee::CLI::Attach
        else
          proc { color_puts("Unknown command: #{@command}", color: :red) }
        end
      end
    end
  end
end
