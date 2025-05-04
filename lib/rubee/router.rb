module Rubee
  class Router
    include Singleton

    HTTP_METHODS = %i[get post put patch delete head connect options trace].freeze unless defined?(HTTP_METHODS)

    attr_reader :request, :routes

    @routes = []

    class << self
      def draw
        yield(self) if block_given?
      end

      def route_for(request)
        puts request.request_method
        method = (request.params['_method'] || request.request_method).downcase.to_sym
        @routes.find do |route|
          return route if request.path == route[:path] && request.request_method&.downcase&.to_sym == route[:method]

          pattern = route[:path].gsub(/{.*?}/, '([^/]+)')
          regex = /^#{pattern}$/
          regex.match?(request.path) && method.to_s == route[:method].to_s
        end
      end

      def set_route(path, to:, method: __method__, **args)
        controller, action = to.split('#')
        @routes.delete_if { |route| route[:path] == path && route[:method] == method }
        @routes << { path:, controller:, action:, method:, **args }
      end

      HTTP_METHODS.each do |method|
        define_method method do |path, to:, **args|
          set_route(path, to:, method: method, **args)
        end
      end
    end
  end
end
