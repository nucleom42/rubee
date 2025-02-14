require 'rack'
require 'json'
require 'pry'
require 'singleton'
require 'sequel'

APP_ROOT = File.expand_path(File.dirname(__FILE__))
IMAGE_DIR = File.join(APP_ROOT, 'images')

module Rubee
  class Application
    include Singleton

    def call(env)
      # autoload rb files
      Autoload.call
      # register images paths
      request = Rack::Request.new(env)
      # Add default path for images
      Router.draw { |route| route.get "/images/{path}", to: "base#image" }
      # define route
      route = Router.route_for(request)
      # init controller class
      raise "There is no path #{request.path} registered" unless route

      controller_class = "#{route[:controller].capitalize}Controller"
      # instantiate controller
      controller = Object.const_get(controller_class).new(request, route)
      # get the action
      action = route[:action]
      # fire the action
      controller.send(action)
    end
  end

  class Configuration
    include Singleton

    @configuraiton = {
      env: ENV['RACK_ENV'],
      development: {
        database_url: "",
        port: 7000
      },
      production: {},
      test: {}
    }

    class << self
      def setup(env)
        yield(self)
      end

      def database_url=(args)
        @configuraiton[args[:env].to_sym][:database_url] = args[:url]
      end

      def method_missing(method_name, *args, &block)
        if method_name.to_s.start_with?("get_")
          @configuraiton[ENV['RACK_ENV']&.to_sym || :development]&.[](method_name.to_s.delete_prefix("get_").to_sym)
        end
      end
    end
  end

  class Router
    include Singleton

    HTTP_METHODS = [:get, :post, :put, :patch, :delete, :head, :connect, :options, :trace].freeze

    attr_reader :request, :routes

    @routes = []

    class << self
      def draw
        yield(self) if block_given?
      end

      def route_for(request)
        puts request.request_method
        @routes.find do |route|
          return route if request.path == route[:path] && request.request_method&.downcase&.to_sym == route[:method]

          pattern = route[:path].gsub(/{.*}/, '(.*)')
          regex = %r{^#{pattern}$}
          regex.match?(request.path) && request.request_method&.downcase&.to_sym == route[:method]
        end
      end

      def set_route(path, to:, method: __method__, **args)
        controller, action = to.split("#")
        @routes.delete_if { |route| route[:path] == path && route[:method]  == method }
        @routes << { path:, controller:, action:, method:, **args }
      end

      HTTP_METHODS.each do |method|
        define_method method do |path, to:, **args|
          set_route(path, to:, method: method, **args)
        end
      end
    end
  end


  class Autoload
    class << self
      def call
        # autoload all rbs
        root_directory = File.dirname(__FILE__)
        # all the base classes should be loaded first
        require_relative "config/base_configuration"
        require_relative "config/routes"
        require_relative "app/controllers/base_controller"
        Dir[File.join(root_directory, 'app/models/extensions/**', '*.rb')].each do |file|
          require_relative file
        end
        require_relative "app/models/database_object"
        require_relative "app/models/sqlite_object"
        Dir[File.join(root_directory, '**', '*.rb')].each do |file|
          require_relative file unless ['rubee.rb'].include?(File.basename(file))
        end
      end
    end
  end

  class Generator
    def initialize(model_name, attributes, controller_name, action_name)
      @model_name = model_name
      @attributes = attributes
      @plural_name = "#{controller_name.to_s.gsub("Controller", "").downcase}"
      @action_name = action_name
      @controller_name = controller_name
    end

    def call
      generate_model if @model_name
      generate_db_file if @model_name
      generate_controller if @controller_name && @action_name
      generate_view if @controller_name
    end

    private

    def generate_model
      if model_file = File.exist?("#{APP_ROOT}/app/models/#{@model_name}.rb")
        puts "Model #{@model_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@model_name.capitalize} < DatabaseObject
          attr_accessor #{@attributes.map { |hash| ":#{hash[:name]}"  }.join(", ")}
        end
      RUBY

      File.open("#{APP_ROOT}/app/models/#{@model_name}.rb", 'w') { |file| file.write(content) }
    end

    def generate_controller
      if controller_file = File.exist?("#{APP_ROOT}/app/controllers/#{@plural_name}_controller.rb")
        puts "Controller #{@plural_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@plural_name.capitalize}Controller < BaseController
          def #{@action_name}
            response_with
          end
        end
      RUBY

      File.open("#{APP_ROOT}/app/controllers/#{@plural_name}_controller.rb", 'w') { |file| file.write(content) }
    end

    def generate_view
      if view_file = File.exist?("#{APP_ROOT}/app/views/#{@plural_name}_#{@action_name}.erb")
        puts "View #{@plural_name}_#{@action_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~ERB
        <h1>#{@plural_name}_#{@action_name} View</h1>
      ERB

      File.open("#{APP_ROOT}/app/views/#{@plural_name}_#{@action_name}.erb", 'w') { |file| file.write(content) }
    end

    def generate_db_file
      if db_file = File.exist?("#{APP_ROOT}/db/create_#{@plural_name}.rb")
        puts "DB file for #{@plural_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        require 'sequel'

        class Create#{@plural_name}
          def call
          end
        end
      RUBY

      File.open("#{APP_ROOT}/db/create_#{@plural_name}.rb", 'w') { |file| file.write(content) }
    end
  end
end

