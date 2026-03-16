require_relative 'test_helper'

describe 'Rubee::Generator' do
  describe 'generates Sequel schema lines' do
    after do
      File.delete('lib/app/models/apple.rb') if File.exist?('lib/app/models/apple.rb')
      # Delete any migration file with timestamp prefix
      Dir.glob('lib/db/*_create_apples.rb').each { |f| File.delete(f) }
    end

    it 'for string with just name' do
      generator = Rubee::Generator.new(nil, nil, nil, nil)

      attribute = { name: 'something', type: :string }

      text = generator.send(:generate_sequel_schema, attribute)

      _(text).must_equal('String :something')
    end

    it 'for string name and options' do
      generator = Rubee::Generator.new(nil, nil, nil, nil)

      attribute = { name: 'something', type: :string, options: { curse: 'squirrel' } }

      text = generator.send(:generate_sequel_schema, attribute)

      _(text).must_equal("String :something, curse: 'squirrel'")
    end
  end

  describe 'generates Sequel file' do
    after do
      File.delete('lib/app/models/apple.rb') if File.exist?('lib/app/models/apple.rb')
      # Delete any migration file with timestamp prefix
      Dir.glob('lib/db/*_create_apples.rb').each { |f| File.delete(f) }
    end

    it 'not without a model' do
      generator = Rubee::Generator.new(nil, nil, nil, nil)
      generator.call

      # Check no migration files exist with any timestamp
      _(Dir.glob('lib/db/*_create_apples.rb').empty?).must_equal(true)
    end

    it 'with a model only' do
      generator = Rubee::Generator.new('apple', nil, 'apples', nil)
      generator.call

      # Find the migration file with timestamp prefix
      migration_files = Dir.glob('lib/db/*_create_apples.rb')
      _(migration_files.size).must_equal(1)

      migration_file = migration_files.first
      _(File.exist?(migration_file)).must_equal(true)

      lines = File.readlines(migration_file).map(&:chomp).join("\n")

      _(lines.include?('class CreateApples')).must_equal(true)
      _(lines.include?('def call')).must_equal(true)
      _(lines.include?('return if Rubee::SequelObject::DB.tables.include?(:apples)')).must_equal(true)
      _(lines.include?('Rubee::SequelObject::DB.create_table(:apples) do')).must_equal(true)
      _(lines.include?('String')).must_equal(false)
      _(lines.include?('end')).must_equal(true)
    end

    it 'with a model with attributes' do
      generator = Rubee::Generator.new('apple', [{ name: 'title', type: :string }, { name: 'content', type: :text }],
'apples', nil)
      generator.call

      migration_files = Dir.glob('lib/db/*_create_apples.rb')
      _(migration_files.size).must_equal(1)

      migration_file = migration_files.first
      lines = File.readlines(migration_file).map(&:chomp).join("\n")

      _(lines.include?('class CreateApples')).must_equal(true)
      _(lines.include?('def call')).must_equal(true)
      _(lines.include?('return if Rubee::SequelObject::DB.tables.include?(:apples)')).must_equal(true)
      _(lines.include?('Rubee::SequelObject::DB.create_table(:apples) do')).must_equal(true)
      _(lines.include?('String :title')).must_equal(true)
      _(lines.include?('String :content, text: true')).must_equal(true)
      _(lines.include?('end')).must_equal(true)
    end

    it 'with a model with different attributes' do
      generator = Rubee::Generator.new('apple',
[{ name: 'id', type: :bigint }, { name: 'colour', type: :string }, { name: 'weight', type: :integer }], 'apples', nil)
      generator.call

      migration_files = Dir.glob('lib/db/*_create_apples.rb')
      migration_file = migration_files.first
      lines = File.readlines(migration_file).map(&:chomp).join("\n")

      _(lines.include?('class CreateApples')).must_equal(true)
      _(lines.include?('def call')).must_equal(true)
      _(lines.include?('return if Rubee::SequelObject::DB.tables.include?(:apples)')).must_equal(true)
      _(lines.include?('Rubee::SequelObject::DB.create_table(:apples) do')).must_equal(true)
      _(lines.include?('Bignum :id')).must_equal(true)
      _(lines.include?('String :colour')).must_equal(true)
      _(lines.include?('Integer :weight')).must_equal(true)
      _(lines.include?('end')).must_equal(true)
    end

    it 'with a model with an attribute with multiple names' do
      generator = Rubee::Generator.new('apple',
[{ name: ['blue_id', 'shoe_id'], type: :foreign_key, table: 'blue_and_shoe_join_tb' }], 'apples', nil)
      generator.call

      migration_files = Dir.glob('lib/db/*_create_apples.rb')
      migration_file = migration_files.first
      lines = File.readlines(migration_file).map(&:chomp).join("\n")

      _(lines.include?('class CreateApples')).must_equal(true)
      _(lines.include?('def call')).must_equal(true)
      _(lines.include?('return if Rubee::SequelObject::DB.tables.include?(:apples)')).must_equal(true)
      _(lines.include?('Rubee::SequelObject::DB.create_table(:apples) do')).must_equal(true)
      _(lines.include?('foreign_key [:blue_id, :shoe_id]')).must_equal(true)
      _(lines.include?(':blue_and_shoe_join_tb')).must_equal(true)
      _(lines.include?('end')).must_equal(true)
    end

    it 'with a model with a foreign_key without table' do
      generator = Rubee::Generator.new('apple', [{ name: 'blue_id', type: :foreign_key }], 'apples', nil)
      generator.call

      migration_files = Dir.glob('lib/db/*_create_apples.rb')
      migration_file = migration_files.first
      lines = File.readlines(migration_file).map(&:chomp).join("\n")

      _(lines.include?('class CreateApples')).must_equal(true)
      _(lines.include?('def call')).must_equal(true)
      _(lines.include?('return if Rubee::SequelObject::DB.tables.include?(:apples)')).must_equal(true)
      _(lines.include?('Rubee::SequelObject::DB.create_table(:apples) do')).must_equal(true)
      _(lines.include?('foreign_key :blue_id')).must_equal(true)
      _(lines.include?('end')).must_equal(true)
    end

    it 'generates migration file with timestamp prefix' do
      generator = Rubee::Generator.new('apple', nil, 'apples', nil)
      generator.call

      migration_files = Dir.glob('lib/db/*_create_apples.rb')
      _(migration_files.size).must_equal(1)

      # Verify timestamp prefix format (YYYYMMDDHHMMSS_create_apples.rb)
      filename = File.basename(migration_files.first)
      _(filename).must_match(/^\d{14}_create_apples\.rb$/)
    end
  end

  describe 'generates Model file' do
    after do
      File.delete('lib/app/models/apple.rb') if File.exist?('lib/app/models/apple.rb')
      Dir.glob('lib/db/*_create_apples.rb').each { |f| File.delete(f) }
    end

    it 'not without a model' do
      generator = Rubee::Generator.new(nil, nil, nil, nil)
      generator.call

      _(File.exist?('lib/app/models/apple.rb')).must_equal(false)
    end

    it 'with a model only' do
      generator = Rubee::Generator.new('apple', nil, 'apples', nil)
      generator.call

      _(File.exist?('lib/app/models/apple.rb')).must_equal(true)

      lines = File.readlines('lib/app/models/apple.rb').map(&:chomp).join("\n")

      _(lines.include?('class Apple < Rubee::SequelObject')).must_equal(true)
      _(lines.include?('attr_accessor')).must_equal(false)
      _(lines.include?('end')).must_equal(true)
    end

    it 'with a model with attributes' do
      generator = Rubee::Generator.new('apple', [{ name: 'title', type: :string }, { name: 'content', type: :text }],
'apples', nil)
      generator.call

      _(File.exist?('lib/app/models/apple.rb')).must_equal(true)

      lines = File.readlines('lib/app/models/apple.rb').map(&:chomp).join("\n")

      _(lines.include?('class Apple < Rubee::SequelObject')).must_equal(true)
      _(lines.include?('attr_accessor')).must_equal(true)
      _(lines.include?(':title, :content')).must_equal(true)
      _(lines.include?('end')).must_equal(true)
    end

    it 'with a model with different attributes' do
      generator = Rubee::Generator.new('apple',
[{ name: 'id', type: :bigInt }, { name: 'colour', type: :string }, { name: 'weight', type: :integer }], 'apples', nil)
      generator.call

      _(File.exist?('lib/app/models/apple.rb')).must_equal(true)

      lines = File.readlines('lib/app/models/apple.rb').map(&:chomp).join("\n")

      _(lines.include?('class Apple < Rubee::SequelObject')).must_equal(true)
      _(lines.include?('attr_accessor')).must_equal(true)
      _(lines.include?(':id, :colour, :weight')).must_equal(true)
      _(lines.include?('end')).must_equal(true)
    end
  end

  describe 'generates View file' do
  end

  describe 'generates Controller file' do
  end
end
