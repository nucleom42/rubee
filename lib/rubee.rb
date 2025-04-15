require 'singleton'
require 'bundler/setup'
require 'bundler'

begin
  Bundler.require(:default)
rescue StandardError
  nil
end

module Rubee
  APP_ROOT = File.expand_path(Dir.pwd) unless defined?(APP_ROOT)
  PROJECT_NAME = File.basename(APP_ROOT) unless defined?(PROJECT_NAME)
  LIB = PROJECT_NAME == 'rubee' ? 'lib/' : '' unless defined?(LIB)
  IMAGE_DIR = File.join(APP_ROOT, LIB, 'images') unless defined?(IMAGE_DIR)
  JS_DIR = File.join(APP_ROOT, LIB, 'js') unless defined?(JS_DIR)
  VERSION = '1.4.0'

  class Application
    include Singleton

    def call(env)
      # autoload rb files
      Autoload.call
      # register images paths
      request = Rack::Request.new(env)
      # Add default path for images
      Router.draw do |route|
        route.get('/images/{path}', to: 'base#image', namespace: 'Rubee')
        route.get('/js/{path}', to: 'base#js', namespace: 'Rubee')
        route.get('/css/{path}', to: 'base#css', namespace: 'Rubee')
      end
      # define route
      route = Router.route_for(request)
      # if react is the view so we would like to delegate not cauth by rubee routes to it.
      if Rubee::Configuration.react[:on] && !route
        index = File.read(File.join(Rubee::APP_ROOT, Rubee::LIB, 'app/views', 'index.html'))
        return [200, { 'content-type' => 'text/html' }, [index]]
      end
      # if not found return 404
      return [404, { 'content-type' => 'text/plain' }, ['Route not found']] unless route
      # init controller class
      controller_class = if route[:namespace]
        "#{route[:namespace]}::#{route[:controller].capitalize}Controller"
      else
        "#{route[:controller].capitalize}Controller"
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
        database_url: '',
        port: 7000,
      },
      production: {},
      test: {},
    }

    class << self
      def setup(_env)
        yield(self)
      end

      def database_url=(args)
        @configuraiton[args[:env].to_sym][:database_url] = args[:url]
      end

      def async_adapter=(args)
        @configuraiton[args[:env].to_sym][:async_adapter] = args[:async_adapter]
      end

      def react=(args)
        @configuraiton[args[:env].to_sym][:react] ||= { on: false }
        @configuraiton[args[:env].to_sym][:react].merge!(on: args[:on])
      end

      def react
        @configuraiton[ENV['RACK_ENV']&.to_sym || :development][:react] || {}
      end

      def method_missing(method_name, *_args)
        return unless method_name.to_s.start_with?('get_')

        @configuraiton[ENV['RACK_ENV']&.to_sym || :development]&.[](method_name.to_s.delete_prefix('get_').to_sym)
      end

      def envs
        @configuraiton.keys
      end
    end
  end

  class Router
    include Singleton

    HTTP_METHODS = %i[get post put patch delete head connect options trace].freeze

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

  class Autoload
    class << self
      def call(black_list = [])
        # autoload all rbs
        root_directory = File.dirname(__FILE__)
        priority_order_require(root_directory, black_list)
        # ensure sequel object is connected
        Rubee::SequelObject.reconnect!

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
        unless black_list.include?('base_configuration.rb')
          require_relative File.join(APP_ROOT, LIB,
                                     'config/base_configuration')
        end
        # This is necessary prerequisitedb init step
        if !defined?(Rubee::SequelObject::DB) && (PROJECT_NAME == 'rubee')
          Rubee::Configuration.setup(env = :test) do |config|
            config.database_url = { url: 'sqlite://lib/tests/test.db', env: }
          end
        end

        require_relative File.join(APP_ROOT, LIB, 'config/routes') unless black_list.include?('routes.rb')
        # rubee extensions
        Dir[File.join(root_directory, 'rubee/extensions/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # rubee controllers
        Dir[File.join(root_directory, 'rubee/controllers/middlewares/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        Dir[File.join(root_directory, 'rubee/controllers/extensions/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        unless black_list.include?('base_controller.rb')
          require_relative File.join(root_directory,
                                     'rubee/controllers/base_controller')
        end
        # rubee models
        unless black_list.include?('database_objectable.rb')
          require_relative File.join(root_directory,
                                     'rubee/models/database_objectable')
        end
        return if black_list.include?('sequel_object.rb')

        require_relative File.join(root_directory,
                                   'rubee/models/sequel_object')
      end
    end
  end

  class Generator
    def initialize(model_name, model_attributes, controller_name, action_name, **options)
      @model_name = model_name&.downcase
      @model_attributes = model_attributes || []
      @plural_name = controller_name.to_s.gsub('Controller', '').downcase.to_s
      @action_name = action_name
      @controller_name = controller_name
      @react = options[:react] || {}
    end

    def call
      generate_model if @model_name
      generate_db_file if @model_name
      generate_controller if @controller_name && @action_name
      generate_view if @controller_name
    end

    private

    def generate_model
      model_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "app/models/#{@model_name}.rb")
      if File.exist?(model_file)
        puts "Model #{@model_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@model_name.capitalize} < Rubee::SequelObject
          attr_accessor #{@model_attributes.map { |hash| ":#{hash[:name]}" }.join(', ')}
        end
      RUBY

      File.open(model_file, 'w') { |file| file.write(content) }
      color_puts("Model #{@model_name} created", color: :green)
    end

    def generate_controller
      controller_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "app/controllers/#{@plural_name}_controller.rb")
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
      color_puts("Controller #{@plural_name} created", color: :green)
    end

    def generate_view
      if @react[:view_name]
        view_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "app/views/#{@react[:view_name]}")
        content = <<~JS
          import React, { useEffect, useState } from "react";
          // 1. Add your logic that fetches data
          // 2. Do not forget to add respective react route
          export function User() {

            return (
              <div>
                <h2>#{@react[:view_name]} view</h2>
              </div>
            );
          }
        JS
      else
        view_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "app/views/#{@plural_name}_#{@action_name}.erb")
        content = <<~ERB
          <h1>#{@plural_name}_#{@action_name} View</h1>
        ERB
      end

      name = @react[:view_name] || "#{@plural_name}_#{@action_name}"

      if File.exist?(view_file)
        puts "View #{name} already exists. Remove it if you want to regenerate"
        return
      end

      File.open(view_file, 'w') { |file| file.write(content) }
      color_puts("View #{name} created", color: :green)
    end

    def generate_db_file
      db_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "db/create_#{@plural_name}.rb")
      if File.exist?(db_file)
        puts "DB file for #{@plural_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class Create#{@plural_name.capitalize}
          def call
            return if Rubee::SequelObject::DB.tables.include?(:#{@plural_name})

            Rubee::SequelObject::DB.create_table(:#{@plural_name}) do
              #{@model_attributes.map { |attribute| generate_sequel_schema(attribute) }.join("\n\t\t\t")}
            end
          end
        end
      RUBY

      File.open(db_file, 'w') { |file| file.write(content) }
      color_puts("DB file for #{@plural_name} created", color: :green)
    end

    def generate_sequel_schema(attribute)
      type = attribute[:type]
      name = if attribute[:name].is_a?(Array)
        attribute[:name].map { |nom| ":#{nom}" }.join(", ").prepend('[') + ']'
      else
        ":#{attribute[:name]}"
      end
      table = attribute[:table] || 'replace_with_table_name'
      options = attribute[:options] || {}

      lookup_hash = {
        primary: "primary_key #{name}",
        string: "String #{name}",
        text: "String #{name}, text: true",
        integer: "Integer #{name}",
        date: "Date #{name}",
        datetime: "DateTime #{name}",
        time: "Time #{name}",
        boolean: "TrueClass #{name}",
        bigint: "Bignum #{name}",
        decimal: "BigDecimal #{name}",
        foreign_key: "foreign_key #{name}, :#{table}",
        index: "index #{name}",
        unique: "unique #"
      }

      statement = lookup_hash[type.to_sym]

      options.keys.each do |key|
        statement += ", #{key}: '#{options[key]}'"
      end

      statement
    end
  end
end
