require_relative '../test_helper'

describe 'Rubee::CLI::Attach' do
  describe 'when run attach command over cli' do
    it 'calls Rubee::CLI::Attach.call' do
      called = false

      Rubee::CLI::Attach.stub(:call, ->(*_args) { called = true }) do
        Rubee::CLI::Command.new(['attach', 'carrot']).call
      end

      assert called, "Expected Rubee::CLI::Attach.run to be called"
    end
  end

  describe 'when attach executed' do
    it 'creates new folder carrot' do
      Rubee::CLI::Command.new(['attach', 'carrot']).call unless Dir.exist?('carrot')
      assert Dir.exist?('carrot'), "Expected 'carrot' folder to be created"
      FileUtils.rm_rf('carrot')
    end

    it 'creates inside of the project folder expected content' do
      Rubee::CLI::Command.new(['attach', 'carrot']).call unless Dir.exist?('carrot')
      %w[controllers models views].each do |dir|
        assert Dir.exist?("carrot/#{dir}"), "Expected 'carrot/#{dir}' folder to be created"
      end

      %w[carrot_configuration carrot_routes carrot_namespace].each do |file|
        assert File.exist?("carrot/#{file}.rb"), "Expected 'carrot/#{file}.rb' file to be created"
      end

      FileUtils.rm_rf('carrot')
    end
  end
end
