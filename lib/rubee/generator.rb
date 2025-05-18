module Rubee
  class Generator
    require_relative '../inits/charged_string'
    using ChargedString

    def initialize(model_name, model_attributes, controller_name, action_name, **options)
      @model_name = model_name&.downcase
      @model_attributes = model_attributes || []
      @base_name = controller_name.to_s.gsub('Controller', '').downcase.to_s
      color_puts("base_name: #{@base_name}", color: :gray)
      @plural_name = @base_name.plural? ? @base_name : @base_name.pluralize
      @action_name = action_name
      @react = options[:react] || {}
      @app_name = options[:app_name] || :app
      @namespace = @app_name == :app ? '' : "#{@app_name.camelize}::"
    end

    def call
      generate_model if @model_name
      generate_db_file if @model_name
      generate_controller if @base_name && @action_name
      generate_view if @base_name
    end

    private

    def generate_model
      model_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "#{@app_name.to_s.snakeize}/models/#{@model_name}.rb")
      if File.exist?(model_file)
        puts "Model #{@model_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@namespace}#{@model_name.camelize} < Rubee::SequelObject
          #{'attr_accessor ' + @model_attributes.map { |hash| ":#{hash[:name]}" }.join(', ') unless @model_attributes.empty?}
        end
      RUBY

      File.open(model_file, 'w') { |file| file.write(content) }
      color_puts("Model #{@model_name} created", color: :green)
    end

    def generate_controller
      controller_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "#{@app_name}/controllers/#{@base_name}_controller.rb")
      if File.exist?(controller_file)
        puts "Controller #{@base_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class #{@namespace}#{@base_name.camelize}Controller < Rubee::BaseController
          def #{@action_name}
            response_with
          end
        end
      RUBY

      File.open(controller_file, 'w') { |file| file.write(content) }
      color_puts("Controller #{@base_name} created", color: :green)
    end

    def generate_view
      prefix = @namespace == "" ? "" : "#{@app_name.snakeize}_"
      if @react[:view_name]
        view_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "#{@app_name}/views/#{@react[:view_name]}")
        content = <<~JS
          import React, { useEffect, useState } from "react";
          // 1. Add your logic that fetches data
          // 2. Do not forget to add respective react route
          export function #{@react[:view_name].gsub(/\.(.*)+$/, '').camelize}() {

            return (
              <div>
                <h2>#{@react[:view_name].gsub(/\.(.*)+$/, '').camelize} view</h2>
              </div>
            );
          }
        JS
      else # erb
        view_file = File.join(
          Rubee::APP_ROOT, Rubee::LIB,
          "#{@app_name}/views/#{prefix}#{@plural_name}_#{@action_name}.erb"
        )
        content = <<~ERB
          <h1>#{prefix}#{@plural_name}_#{@action_name} View</h1>
        ERB
      end

      name = @react[:view_name] || "#{prefix}#{@plural_name}_#{@action_name}"

      if File.exist?(view_file)
        puts "View #{name} already exists. Remove it if you want to regenerate"
        return
      end

      File.open(view_file, 'w') { |file| file.write(content) }
      color_puts("View #{name} created", color: :green)
    end

    def generate_db_file
      table_name = @namespace == "" ? @plural_name : "#{@namespace.snakeize}_#{@plural_name}"
      db_file = File.join(Rubee::APP_ROOT, Rubee::LIB, "db/create_#{table_name}.rb")
      if File.exist?(db_file)
        puts "DB file for #{table_name} already exists. Remove it if you want to regenerate"
        return
      end

      content = <<~RUBY
        class Create#{table_name.camelize}
          def call
            return if Rubee::SequelObject::DB.tables.include?(:#{table_name})

            Rubee::SequelObject::DB.create_table(:#{table_name}) do
              #{@model_attributes.map { |attribute| generate_sequel_schema(attribute) }.join("\n\t\t\t")}
            end
          end
        end
      RUBY

      File.open(db_file, 'w') { |file| file.write(content) }
      color_puts("DB file for #{table_name} created", color: :green)
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
        unique: "unique #",
      }

      statement = lookup_hash[type.to_sym]

      options.keys.each do |key|
        statement += ", #{key}: '#{options[key]}'"
      end

      statement
    end
  end
end
