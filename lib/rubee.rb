require "singleton"
require "bundler/setup"
require 'bundler'

Bundler.require(:default) rescue nil

module Rubee
  APP_ROOT = File.expand_path(Dir.pwd) unless defined?(APP_ROOT)
  IMAGE_DIR = File.join(APP_ROOT, 'images') unless defined?(IMAGE_DIR)
  PROJECT_NAME = File.basename(APP_ROOT) unless defined?(PROJECT_NAME)
  VERSION = '1.1.4'

  class Application
    include Singleton

    def call(env)
      # autoload rb files
      Autoload.call
      # register images paths
      request = Rack::Request.new(env)
      # Add default path for images
      Router.draw { |route| route.get "/images/{path}", to: "base#image", namespace: "Rubee"}
      # define route
      route = Router.route_for(request)
      # init controller class
      return [404, { "content-type" => "text/plain" }, ["Route not found"]] unless route

      if route[:namespace]
        controller_class = "#{route[:namespace]}::#{route[:controller].capitalize}Controller"
      else
        controller_class = "#{route[:controller].capitalize}Controller"
      end
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

      def async_adapter=(args)
        @configuraiton[args[:env].to_sym][:async_adapter] = args[:async_adapter]
      end

      def method_missing(method_name, *args, &block)
        if method_name.to_s.start_with?("get_")
          @configuraiton[ENV['RACK_ENV']&.to_sym || :development]&.[](method_name.to_s.delete_prefix("get_").to_sym)
        end
      end

      def envs
        @configuraiton.keys
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
        method = (request.params["_method"] || request.request_method).downcase.to_sym
        @routes.find do |route|
          return route if request.path == route[:path] && request.request_method&.downcase&.to_sym == route[:method]

          pattern = route[:path].gsub(/{.*?}/, '([^/]+)')
          regex = %r{^#{pattern}$}
          regex.match?(request.path) && method.to_s == route[:method].to_s
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
      def call(black_list=[])
        # autoload all rbs
        root_directory = File.dirname(__FILE__)
        priority_order_require(root_directory, black_list)

        Dir.glob(File.join(APP_ROOT, '**', '*.rb')).sort.each do |file|
          base_name = File.basename(file)

          unless base_name.end_with?('_test.rb') || (black_list + ['rubee.rb', 'test_helper.rb']).include?(base_name)
            require_relative file
          end
        end
      end

      def priority_order_require(root_directory, black_list)
        # rubee inits
        Dir[File.join(root_directory, 'inits/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # app inits
        Dir[File.join(APP_ROOT, 'inits/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # rubee async
        Dir[File.join(root_directory, 'rubee/async/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # app config and routes
        lib = PROJECT_NAME == 'rubee' ? 'lib/' : ''
        require_relative File.join(APP_ROOT, lib, "config/base_configuration") unless black_list.include?('base_configuration.rb')
        require_relative File.join(APP_ROOT, lib, "config/routes") unless black_list.include?('routes.rb')
        # rubee extensions
        Dir[File.join(root_directory, "rubee/extensions/**", '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # rubee controllers
        Dir[File.join(root_directory, 'rubee/controllers/middlewares/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        Dir[File.join(root_directory, 'rubee/controllers/extensions/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        require_relative File.join(root_directory, "rubee/controllers/base_controller") unless black_list.include?('base_controller.rb')
        # rubee models
        require_relative File.join(root_directory, "rubee/models/database_object") unless black_list.include?('database_object.rb')
        require_relative File.join(root_directory, "rubee/models/sequel_object") unless black_list.include?('sequel_object.rb')
      end
    end
  end

  class Generator
    def initialize(model_name, attributes, controller_name, action_name)
      @model_name = model_name&.downcase
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
      model_file = File.join("app/models/#{@model_name}.rb")
      if File.exist?(model_file)
        puts "Model #{@model_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@model_name.capitalize} < Rubee::SequelObject
          attr_accessor #{@attributes.map { |hash| ":#{hash[:name]}"  }.join(", ")}
        end
      RUBY

      File.open(model_file, 'w') { |file| file.write(content) }
      color_puts "Model #{@model_name} created", color: :green
    end

    def generate_controller
      controller_file = File.join("app/controllers/#{@plural_name}_controller.rb")
      if File.exist?(controller_file)
        puts "Controller #{@plural_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@plural_name.capitalize}Controller < Rubee::BaseController
          def #{@action_name}
            response_with
          end
        end
      RUBY

      File.open(controller_file, 'w') { |file| file.write(content) }
      color_puts "Controller #{@plural_name} created", color: :green
    end

    def generate_view
      view_file = File.join("app/views/#{@plural_name}_#{@action_name}.erb")
      if File.exist?(view_file)
        puts "View #{@plural_name}_#{@action_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~ERB
        <h1>#{@plural_name}_#{@action_name} View</h1>
      ERB

      File.open(view_file, 'w') { |file| file.write(content) }
      color_puts "View #{@plural_name}_#{@action_name} created", color: :green
    end

    def generate_db_file
      db_file = File.join("db/create_#{@plural_name}.rb")
      if File.exist?(db_file)
        puts "DB file for #{@plural_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class Create#{@plural_name.capitalize}
          def call
          end
        end
      RUBY

      File.open(db_file, 'w') { |file| file.write(content) }
      color_puts "DB file for #{@plural_name} created", color: :green
    end
  end
end

