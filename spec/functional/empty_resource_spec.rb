require 'spec_helper'

require 'rack/test'

require 'functional/empty_resource/services/empty_resource'

describe Spec::Functional::EmptyResource,
         { :work_dir => "#{File.dirname(__FILE__ )}/empty_resource" } do
  include Rack::Test::Methods

  def app
    Spec::Functional::EmptyResource.new
  end

  it 'responds to /' do
    get '/'

    last_response.status.should eq(200)
  end

  describe 'when a unknown url' do

    let(:url) { '/empty_resource/api/0.1/unknown' }

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

    let(:url) { '/empty_resource/doc/0.1' }

    it 'returns a success status' do
      get url

      last_response.status.should eq(200)
    end

    context 'when no format' do
      it 'sets a html content type' do
        get url

        last_response.header['Content-Type'].should eq('text/html')
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