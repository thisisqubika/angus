require 'spec_helper'

require 'angus-router'

require 'angus/rspec/support/examples/describe_errors'

describe Angus::RSpec::Examples::DescribeErrors do

  subject(:descriptor) { Angus::RSpec::Examples::DescribeErrors }

  let(:base) do
    Class.new do
      def self.get(path, &block)
        :get_v0
      end

      def router
        @router ||= Angus::Router.new
      end
    end
  end

  let(:error) { StandardError }

  let(:example) { double(:example, :app => base) }

  describe '.mock_service' do

    it 'mocks app method' do
      mocked_app = nil

      descriptor.mock_service(base, error, example) do
        mocked_app = example.app
      end

      mocked_app.should_not eq(base)
    end

    it 'binds to the original app method after running' do
      example.app.should eq(base)
      descriptor.mock_service(base, error, example) { }

      example.app.should eq(base)
    end

    context 'when exception occurs' do
      it 'binds to the original app method after running' do
        example.app.should eq(base)

        begin
          descriptor.mock_service(base, error, example) do
            raise StandardError
          end
        rescue
        end

        example.app.should eq(base)
      end

      it 'reraises the exception' do
        expect {
          descriptor.mock_service(base, error, example) do
            raise StandardError
          end
        }.to raise_error(StandardError)
      end
    end
  end

end
