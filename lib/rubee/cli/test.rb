module Rubee
  module CLI
    module Test
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def test(argv)
          ENV['RACK_ENV'] = 'test'
          file_name = argv[1] # Get the first argument
          line = argv[2]&.start_with?('--line=') ? argv[2].split('=')[1] : nil
          lib = Rubee::PROJECT_NAME == 'rubee' ? '/lib' : ''
          if file_name && !line
            color_puts("Running #{file_name} test ...", color: :yellow)
            exec("ruby -Itest -e \"require '.#{lib}/tests/#{file_name}'\"")
          elsif file_name && line
            color_puts("Running #{file_name} test at line #{line} ...", color: :yellow)
            test_name = find_test_at_line(".#{lib}/tests/#{file_name}", line)
            exec("ruby -Itest .#{lib}/tests/#{file_name} -n #{test_name}")
          else
            color_puts('Running all tests ...', color: :yellow)
            exec("ruby -Itest -e \"Dir.glob('.#{lib}/tests/**/*_test.rb').each { |file| require file }\"")
          end
        end

        private

        def find_test_at_line(file, line)
          source = File.read(file).lines
          name   = nil
          kind   = nil

          # 1. Look backwards from the line
          source[0...line.to_i].reverse_each do |l|
            if l =~ /^\s*def\s+(test_\w+)/
              name = ::Regexp.last_match(1)
              kind = :method
              break
            elsif l =~ /^\s*describe\s+['"](.*)['"]/
              name = ::Regexp.last_match(1)
              kind = :spec
              break
            elsif l =~ /^\s*it\s+['"](.*)['"]/
              name = ::Regexp.last_match(1)
              kind = :spec
              break
            end
          end

          # 2. If nothing was found, fallback to first def/it in the file
          if name.nil?
            source.each do |l|
              if l =~ /^\s*def\s+(test_\w+)/
                name = ::Regexp.last_match(1)
                kind = :method
                break
              elsif l =~ /^\s*describe\s+['"](.*)['"]/
                name = ::Regexp.last_match(1)
                kind = :spec
                break
              elsif l =~ /^\s*it\s+['"](.*)['"]/
                name = ::Regexp.last_match(1)
                kind = :spec
                break
              end
            end
          end

          # 3. Return correct `-n` filter
          if kind == :spec
            "/#{Regexp.escape(name)}/"
          else
            name
          end
        end
      end
    end
  end
end
