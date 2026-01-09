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

        def drop_tables(_argv)
          out = Rubee::SequelObject::DB.tables.each { |table| Rubee::SequelObject::DB.drop_table(table, cascade: true) }
          color_puts("These tables has been dropped for #{ENV['RACK_ENV']} env", color: :cyan)
          color_puts(out, color: :gray)
        end

        def schema(argv)
          target_table_hash = argv[2] ? { argv[2].to_sym => STRUCTURE[argv[2].to_sym] } : nil
          (target_table_hash || STRUCTURE).each do |table_name, table_def|
            unless Rubee::SequelObject::DB.table_exists?(table_name.to_sym)
              color_puts("Table #{table_name} not found", color: :red)
              next
            end
            columns = table_def[:columns]
            foreign_keys = table_def[:foreign_keys] || []

            # Table header
            color_puts(
              "--- #{table_name}",
              color: :cyan,
              style: :bold
            )

            # Columns
            columns.each do |column_name, meta|
              parts = []

              # column name
              parts << "- #{column_name}"

              # PK
              parts << "(PK)" if meta[:primary_key]

              # type
              parts << "type (#{meta[:db_type]})" if meta[:db_type]

              # nullable
              parts << "nullable" if meta[:allow_null]

              line = parts.join(", ")

              color_puts(
                line,
                color: meta[:primary_key] ? :yellow : :gray
              )
            end

            # Foreign keys
            if foreign_keys.any?
              puts
              color_puts("  Foreign keys:", color: :magenta, style: :bold)

              foreign_keys.each do |fk|
                cols = Array(fk[:columns]).join(", ")

                ref_table =
                  fk.dig(:references, :table) ||
                  fk[:table]

                ref_cols =
                  Array(fk.dig(:references, :columns)) || fk["id"]

                fk_line = "  - #{cols} → #{ref_table}(#{ref_cols.join(', ')})"

                fk_line += " on delete #{fk[:on_delete]}" if fk[:on_delete]
                fk_line += " on update #{fk[:on_update]}" if fk[:on_update]

                color_puts(fk_line, color: :gray)
              end
            end

            puts
          end
        end

        private

        def generate_structure
          schema_hash = {}

          Rubee::SequelObject::DB.tables.each do |table|
            schema_hash[table] = {
              columns: {},
              foreign_keys: [],
            }

            # Columns
            Rubee::SequelObject::DB.schema(table).each do |column, details|
              schema_hash[table][:columns][column] = details
            end

            # Foreign keys
            Rubee::SequelObject::DB.foreign_key_list(table).each do |fk|
              schema_hash[table][:foreign_keys] << {
                name: fk[:name],
                columns: fk[:columns],
                references: {
                  table: fk[:table],
                  columns: fk[:key],
                },
                on_delete: fk[:on_delete],
                on_update: fk[:on_update],
              }.compact
            end
          end

          formatted_hash =
            JSON.pretty_generate(schema_hash)
              .gsub(/"(\w+)":/, '\1:')
              .gsub(': null', ': nil')
          file_path = File.join(Rubee::APP_ROOT, Rubee::LIB, "db/structure.rb")
          File.open(file_path, 'w') do |file|
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
