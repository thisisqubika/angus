# spec/angus/generator/generator_spec.rb
require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require 'angus/commands/command_processor'

RSpec.describe 'Angus Generator' do
  let(:temp_dir) { Dir.mktmpdir }
  let(:processor) { Angus::CommandProcessor.new }

  after do
    FileUtils.rm_rf(temp_dir) if File.exist?(temp_dir)
  end

  describe 'new_project generator' do
    around do |example|
      example.metadata[:work_dir] = temp_dir
      example.run
    end

    it 'creates a new project with required files' do
      project_name = 'test_api'

      Dir.chdir(temp_dir) do
        processor.new_service(project_name)
      end

      project_dir = File.join(temp_dir, project_name)

      expect(Dir.exist?(project_dir)).to be true
      expect(File.exist?(File.join(project_dir, 'config.ru'))).to be true
      expect(File.exist?(File.join(project_dir, 'Gemfile'))).to be true

      expect(Dir.exist?(File.join(project_dir, 'definitions'))).to be true
      expect(Dir.exist?(File.join(project_dir, 'resources'))).to be true
      expect(Dir.exist?(File.join(project_dir, 'services'))).to be true

      expect(File.exist?(File.join(project_dir, 'definitions', 'messages.yml'))).to be true
      expect(File.exist?(File.join(project_dir, 'definitions', 'representations.yml'))).to be true
      expect(File.exist?(File.join(project_dir, 'definitions', 'service.yml'))).to be true

      service_file = File.join(project_dir, 'services', 'test_api.rb')
      expect(File.exist?(service_file)).to be true

      service_content = File.read(service_file)
      expect(service_content).to include('class TestApi < Angus::Base')
      expect(service_content).to include('def configure')
    end
  end

  describe 'resource generator' do
    let(:project_dir) { File.join(temp_dir, 'test_api') }

    around do |example|
      example.metadata[:work_dir] = project_dir
      example.run
    end

    before do
      Dir.chdir(temp_dir) do
        processor.new_service('test_api')
      end
    end

    it 'creates a new resource with required files' do
      resource_name = 'user'

      Dir.chdir(project_dir) do
        processor.new_resource(resource_name, %w[index show create update destroy])
      end

      resource_file = File.join(project_dir, 'resources', 'users.rb')
      expect(File.exist?(resource_file)).to be true

      operations_file = File.join(project_dir, 'definitions', 'users', 'operations.yml')
      expect(File.exist?(operations_file)).to be true

      resource_content = File.read(resource_file)
      expect(resource_content).to include('class Users < Angus::BaseResource')
      expect(resource_content).to include('def index')
      expect(resource_content).to include('def show')
      expect(resource_content).to include('def create')
      expect(resource_content).to include('def update')
      expect(resource_content).to include('def destroy')

      operations_content = File.read(operations_file)
      expect(operations_content).to include('index:')
      expect(operations_content).to include('show:')
      expect(operations_content).to include('create:')
      expect(operations_content).to include('update:')
      expect(operations_content).to include('destroy:')
    end

    it 'handles complex resource names' do
      resource_name = 'user_profile'

      Dir.chdir(project_dir) do
        processor.new_resource(resource_name, %w[index])
      end

      resource_file = File.join(project_dir, 'resources', 'user_profiles.rb')
      expect(File.exist?(resource_file)).to be true

      operations_file = File.join(project_dir, 'definitions', 'user_profiles', 'operations.yml')
      expect(File.exist?(operations_file)).to be true

      resource_content = File.read(resource_file)
      expect(resource_content).to include('class UserProfiles < Angus::BaseResource')
    end
  end
end
