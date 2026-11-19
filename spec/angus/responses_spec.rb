require 'spec_helper'

require 'json'
require 'angus/responses'

describe Angus::Responses do

  let(:message_definition) do
    Struct.new(:level, :text, :description)
  end

  let(:definitions) do
    messages = {
      'created' => message_definition.new('INFO', nil, 'Created ok'),
      'greeting' => message_definition.new('INFO', 'Hello %s', nil)
    }

    double(:definitions, messages: messages)
  end

  let(:host_class) do
    Class.new do
      include Angus::Responses

      def initialize(definitions)
        @definitions = definitions
      end
    end
  end

  subject(:host) { host_class.new(definitions) }

  describe '#build_success_response' do
    it 'adds the success status to the elements' do
      response = JSON.parse(host.build_success_response(name: 'John'))

      expect(response).to eq('status' => 'success', 'name' => 'John')
    end

    it 'includes the messages when there are any' do
      messages = [{ level: 'INFO', key: 'created', dsc: 'Created ok' }]

      response = JSON.parse(host.build_success_response({ name: 'John' }, [], messages))

      expect(response['messages']).to eq([{ 'level' => 'INFO', 'key' => 'created', 'dsc' => 'Created ok' }])
    end

    it 'removes the optional fields' do
      elements = { name: 'John', address: { street: 'Main', city: 'Salto' } }

      response = JSON.parse(host.build_success_response(elements, ['address.street']))

      expect(response['address']).to eq('city' => 'Salto')
    end

    it 'removes the optional fields inside arrays' do
      elements = { people: [{ name: 'John', age: 3 }, { name: 'Ann', age: 4 }] }

      response = JSON.parse(host.build_success_response(elements, ['people.age']))

      expect(response['people']).to eq([{ 'name' => 'John' }, { 'name' => 'Ann' }])
    end

    it 'drops optional fields that were left empty' do
      elements = { name: 'John', address: { street: 'Main' } }

      response = JSON.parse(host.build_success_response(elements, ['address.street', 'address']))

      expect(response).to eq('status' => 'success', 'name' => 'John')
    end

    it 'keeps the optional fields requested in extra_response_attributes' do
      elements = { name: 'John', age: 3, extra_response_attributes: ['age'] }

      response = JSON.parse(host.build_success_response(elements, ['age']))

      expect(response).to eq('status' => 'success', 'name' => 'John', 'age' => 3)
    end
  end

  describe '#build_message' do
    it 'uses the description of the message definition' do
      expect(host.build_message(:created, 'INFO'))
        .to eq(level: 'INFO', key: :created, dsc: 'Created ok')
    end

    it 'formats the message text with the given params' do
      expect(host.build_message(:greeting, 'info', 'Ann'))
        .to eq(level: 'info', key: :greeting, dsc: 'Hello Ann')
    end

    it 'raises NameError when there is no message for the key and level' do
      expect { host.build_message(:unknown, 'INFO') }.to raise_error(NameError, /unknown/)
    end
  end

  describe '#build_messages' do
    it 'builds a message for each key' do
      expect(host.build_messages('INFO', [:created])).to eq([{ level: 'INFO', key: :created, dsc: 'Created ok' }])
    end

    it 'returns an empty list when there are no messages' do
      expect(host.build_messages('INFO', nil)).to eq([])
    end
  end

  describe '#json' do
    it 'escapes non ascii characters' do
      expect(host.json(name: "\u00d1and\u00fa")).to eq('{"name":"' + '\\' + 'u00d1and' + '\\' + 'u00fa"}')
    end
  end
end
