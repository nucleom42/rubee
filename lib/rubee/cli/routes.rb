module Rubee
  module CLI
    class Routes
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def routes(_argv)
          routes = Rubee::Router.instance_variable_get(:@routes)

          color_puts(routes, color: :green)
        end
      end
    end
  end
end
