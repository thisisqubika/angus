require 'spec_helper'

require 'rack/test'

require 'functional/empty_resource/services/empty_resource'

describe Spec::Functional::EmptyResource,
         { :work_dir => "#{File.dirname(__FILE__ )}/empty_resource" } do
  include Rack::Test::Methods

  subject(:app) { Rack::Lint.new(Spec::Functional::EmptyResource.new) }

  it 'responds to /' do
    get '/'

    expect(last_response.status).to eq(200)
  end

  describe 'when an unknown url' do

    let(:url) { '/empty_resource/api/0.1/unknown' }

    it 'responds to /basic/doc/0.1' do
      get url

      expect(last_response.status).to eq(404)
    end

    it 'sets a json content type' do
      get url

      expect(last_response.header['Content-Type']).to eq('application/json')
    end

  end

  describe 'the documentation url' do

    let(:url) { '/empty_resource/doc/0.1' }

    it 'returns a success status' do
      get url

      expect(last_response.status).to eq(200)
    end

    context 'when no format' do
      it 'sets an html content type' do
        get url

        expect(last_response.header['Content-Type']).to eq('text/html;charset=utf-8')
      end
    end

    context 'when json format' do
      it 'sets a json content type' do
        get "#{url}?format=json"

        expect(last_response.header['Content-Type']).to eq('application/json')
      end
    end

  end

end