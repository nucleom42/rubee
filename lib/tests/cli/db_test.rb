require_relative '../test_helper'

describe 'Rubee::CLI::Db' do
  describe 'when run db run:all with no ENV set' do
    it 'goes with no errors' do
      out = capture_stdout do
        Rubee::CLI::Command.new(['db', 'run:create_dummies']).call
      end

      _(out).must_equal(
        "\e[0;36mRun create_dummies file for test env\e[0m
\e[0;32mMigration for create_dummies completed\e[0m
"
      )

      Rubee::SequelObject::DB.drop_table(:dummies)
    end

    it 'cretes dummies table' do
      Rubee::SequelObject::DB.drop_table(:dummies) if Rubee::SequelObject::DB.tables.include?(:dummies)

      _(Rubee::SequelObject::DB.tables.include?(:dummies)).must_equal false
      Rubee::CLI::Command.new(['db', 'run:create_dummies']).call
      _(Rubee::SequelObject::DB.tables.include?(:dummies)).must_equal true

      Rubee::SequelObject::DB.drop_table(:dummies)
    end
  end
end
