module Rubee
  module CLI
    class Routes
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def routes(_argv)
          routes = Rubee::Router.instance_variable_get(:@routes)
          format_routes(routes)
        end

        def format_routes(routes)
          if routes.nil? || routes.empty?
            color_puts("No routes found", color: :yellow)
            return
          end

          # Group routes by controller
          grouped = routes.group_by { |r| r[:controller] }

          # Calculate the total width
          width = 100

          puts ""
          color_puts('═' * width, color: :cyan)
          color_puts("  APPLICATION ROUTES", color: :cyan, style: :bold)
          color_puts('═' * width, color: :cyan)
          puts ""

          grouped.each do |controller, controller_routes|
            # Controller header with dynamic padding
            header_text = "┌─ #{controller.upcase} "
            padding = '─' * (width - header_text.length)
            color_puts(header_text + padding, color: :gray, style: :bold)

            controller_routes.each do |route|
              print_route(route)
            end

            # Bottom border
            color_puts("└#{'─' * (width - 1)}", color: :gray)
          end

          puts ""
          color_puts("Total routes: #{routes.count}", color: :cyan, style: :bold)
        end

        private

        def print_route(route)
          # Method (GET, POST, etc)
          method = route[:method].to_s.upcase.ljust(7)
          method_color = method_color(route[:method])

          # Path
          path = route[:path].ljust(50)

          # Action
          action = route[:action] || '-'

          # Namespace
          namespace = route[:namespace] ? " [#{route[:namespace]}]" : ""

          # Model info if present
          model_info = route[:model] ? " (#{route[:model][:name]})" : ""

          # Build the line with inline colors using color_puts with inline: true
          print "  "
          color_puts(method, color: method_color, style: :bold, inline: true)
          print " "
          color_puts(path, color: :white, inline: true)
          print " → "
          color_puts(action, color: :cyan, inline: true)
          color_puts(namespace, color: :gray, inline: true)
          color_puts(model_info, color: :gray, inline: true)
          puts ""
        end

        def method_color(method)
          case method.to_s.downcase.to_sym
          when :get
            :green
          when :post
            :cyan
          when :put, :patch
            :yellow
          when :delete
            :red
          else
            :white
          end
        end
      end
    end
  end
end
