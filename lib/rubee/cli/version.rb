module Rubee
  module CLI
    class Version
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def version(_argv)
          color_puts("ruBee v#{Rubee::VERSION}", color: :yellow)
        end
      end
    end
  end
end
