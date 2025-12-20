module Rubee
  module CLI
    module Db
      class << self
        def call(command, argv)
          command = argv[1].split(':').first
          ENV['RACK_ENV'] ||= 'development'
          send(command, argv)
        end

        def run(argv)
          _, file_name = argv[1]&.split(':')
          file_names = if file_name == 'all'
            lib = Rubee::PROJECT_NAME == 'rubee' ? '/lib' : ''
            Dir.glob(".#{lib}/db/*.rb").map do |file|
              File.basename(file, '.rb')
            end.reject { |file| file == 'structure' }
          else
            [file_name]
          end
          file_names.each do |file|
            color_puts("Run #{file} file for #{ENV['RACK_ENV']} env", color: :cyan)
            Object.const_get(file.split('_').map(&:capitalize).join).new.call
          end
          color_puts("Migration for #{file_name} completed", color: :green)
          unless Rubee::PROJECT_NAME == 'rubee'
            color_puts('Regenerate schema file', color: :cyan)
            generate_structure
          end
        end

        def init(_argv)
          ensure_database_exists(Rubee::Configuration.get_database_url)
        end

        def structure(_argv)
          generate_structure
        end

        def schema(_argv)
          STRUCTURE.each do |table_name, columns|
            # Table header
            color_puts(
              "--- #{table_name}",
              color: :cyan,
              style: :bold
            )

            columns.each do |column_name, meta|
              parts = []

              # column name
              col_text = "- #{column_name}"
              parts << col_text

              # PK
              if meta[:primary_key]
                parts << "(PK)"
              end

              # type
              if meta[:db_type]
                parts << "type (#{meta[:db_type]})"
              end

              line = parts.join(", ")

              color_puts(
                line,
                color: meta[:primary_key] ? :yellow : :gray
              )
            end

            puts
          end
        end

        private

        def generate_structure
          schema_hash = {}

          Rubee::SequelObject::DB.tables.each do |table|
            schema_hash[table] = {}

            Rubee::SequelObject::DB.schema(table).each do |column, details|
              schema_hash[table][column] = details
            end
          end
          formatted_hash = JSON.pretty_generate(schema_hash)
            .gsub(/"(\w+)":/, '\1:') # Convert keys to symbols
            .gsub(': null', ': nil') # Convert `null` to `nil`

          File.open('db/structure.rb', 'w') do |file|
            file.puts "STRUCTURE = #{formatted_hash}"
          end

          color_puts('db/structure.rb updated', color: :green)
        end

        def ensure_database_exists(db_url)
          uri = URI.parse(db_url)
          case uri.scheme
          when 'sqlite'
            begin
              Sequel.connect(db_url)
              color_puts("Database #{ENV['RACK_ENV']} exists", color: :cyan)
            rescue => _e
              if File.exist?(db_path = db_url.sub(%r{^sqlite://}, ''))
                color_puts("Database #{ENV['RACK_ENV']} exists", color: :cyan)
              else
                db_path = "#{Rubee::LIB}/#{db_path}" if Rubee::PROJECT_NAME == 'rubee'
                Sequel.sqlite(db_path)
                color_puts("Database #{ENV['RACK_ENV']} created", color: :green)
              end
            end
          when 'postgres'
            begin
              Sequel.connect(db_url)
              color_puts("Database #{ENV['RACK_ENV']} exists", color: :cyan)
            rescue StandardError => _e
              con = Sequel.connect(Rubee::Configuration.get_database_url.gsub(%r{(/test|/development|/production)},
        ''))
              con.run("CREATE DATABASE #{ENV['RACK_ENV']}")
              color_puts("Database #{ENV['RACK_ENV']} created", color: :green)
            end
          else
            color_puts("Unsupported database type: #{db_url}", color: :red)
          end
        end
      end
    end
  end
end
