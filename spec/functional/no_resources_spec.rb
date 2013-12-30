require 'spec_helper'

require 'rack/test'

require 'functional/no_resources/services/no_resources'

describe Spec::Functional::NoResources,
         { :work_dir => "#{File.dirname(__FILE__ )}/no_resources" } do
  include Rack::Test::Methods

  subject(:app) { Rack::Lint.new(Spec::Functional::NoResources.new) }

  it 'responds to /' do
    get '/'

    last_response.status.should eq(200)
  end

  describe 'when a unknown url' do

    let(:url) { '/no_resources/api/0.1/unknown' }

    it 'responds to /basic/doc/0.1' do
      get url

      last_response.status.should eq(404)
    end

    it 'sets a json content type' do
      get url

      last_response.header['Content-Type'].should eq('application/json')
    end

  end

  describe 'the documentation url' do

    let(:url) { '/no_resources/doc/0.1' }

    it 'returns a success status' do
      get url

      last_response.status.should eq(200)
    end

    context 'when no format' do
      it 'sets a html content type' do
        get url

        last_response.header['Content-Type'].should eq('text/html;charset=utf-8')
      end
    end

    context 'when json format' do
      it 'sets a json content type' do
        get "#{url}?format=json"

        last_response.header['Content-Type'].should eq('application/json')
      end
    end

  end

end