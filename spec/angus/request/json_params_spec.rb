require 'spec_helper'

require 'rbconfig'
require 'stringio'
require 'open3'
require 'angus/request/json_params'

describe Angus::Request::JsonParams do

  let(:host_class) do
    Class.new do
      include Angus::Request::JsonParams

      attr_reader :request

      def initialize(body)
        @request = Struct.new(:body).new(StringIO.new(body))
      end
    end
  end

  let(:body) { '{}' }

  subject(:params) { host_class.new(body) }

  describe '#json_body' do
    let(:body) { '{"name": "John", "address": {"city": "Montevideo"}}' }

    it 'returns the body with symbolized keys' do
      expect(params.json_body).to eq(name: 'John', address: { city: 'Montevideo' })
    end

    context 'when the body is not a valid json' do
      let(:body) { '{not json' }

      it 'raises InvalidRequestFormat' do
        expect { params.json_body }.to raise_error(Angus::Exceptions::InvalidRequestFormat)
      end
    end
  end

  describe '#get_json_param' do
    let(:body) { '{"name": "John"}' }

    it 'returns the value of a string or symbol param' do
      expect(params.get_json_param(:name)).to eq('John')
      expect(params.get_json_param('name')).to eq('John')
    end

    it 'returns nil when an optional param is missing' do
      expect(params.get_json_param(:other)).to be_nil
    end
  end

  describe '#get_json_integer' do
    let(:body) { '{"amount": "15", "bad": "abc"}' }

    it 'parses the value as an integer' do
      expect(params.get_json_integer(:amount)).to eq(15)
    end

    it 'raises InvalidValueError when the value is not an integer' do
      expect { params.get_json_integer(:bad) }
        .to raise_error(Angus::Exceptions::InvalidValueError, 'Invalid value abc for param bad')
    end
  end

  describe '#get_json_boolean' do
    let(:body) { '{"a": true, "b": "true", "c": false, "d": "no"}' }

    it 'is true for true and "true"' do
      expect(params.get_json_boolean(:a)).to be(true)
      expect(params.get_json_boolean(:b)).to be(true)
    end

    it 'is false for any other value' do
      expect(params.get_json_boolean(:c)).to be(false)
      expect(params.get_json_boolean(:d)).to be(false)
    end

    it 'raises MissingParameterError when a required param is missing' do
      expect { params.get_json_boolean(:missing) }
        .to raise_error(Angus::Exceptions::MissingParameterError, 'The parameter missing is missing.')
    end

    it 'returns false when an optional param is missing' do
      expect(params.get_json_boolean(:missing, false)).to be(false)
    end
  end

  describe '#get_json_datetime' do
    let(:body) { '{"at": "2024-03-05T10:20:30Z", "bad": "not a date"}' }

    it 'parses the value as a time' do
      expect(params.get_json_datetime(:at)).to eq(Time.utc(2024, 3, 5, 10, 20, 30))
    end

    # Other libraries usually load 'time' first, so this runs in a clean interpreter.
    it 'parses dates without relying on another library to have required time' do
      script = <<-RUBY
        require 'json'
        require 'stringio'
        require 'angus/request/json_params'

        host = Class.new do
          include Angus::Request::JsonParams
          def request; Struct.new(:body).new(StringIO.new('{"at": "2024-03-05T10:20:30Z"}')); end
        end

        puts host.new.get_json_datetime(:at).utc.strftime('%F')
      RUBY

      lib = File.expand_path('../../../lib', __dir__)
      output, status = Open3.capture2e(RbConfig.ruby, '--disable-gems', "-I#{lib}", '-e', script)

      expect(status).to be_success, output
      expect(output).to include('2024-03-05')
    end

    it 'raises InvalidValueError when the value is not a date' do
      expect { params.get_json_datetime(:bad) }
        .to raise_error(Angus::Exceptions::InvalidValueError, 'Invalid value not a date for param bad')
    end
  end
end
