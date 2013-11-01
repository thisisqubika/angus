require 'spec_helper'

require 'rack/test'

require 'functional/basic/services/basic'

describe Spec::Functional::Basic, { :work_dir => "#{File.dirname(__FILE__ )}/basic" } do
  include Rack::Test::Methods

  def app
    Spec::Functional::Basic.new
  end

  it 'responds to /' do
    get '/'

    last_response.status.should eq(200)
  end

  describe 'the documentation url' do

    it 'responds to /basic/doc/0.1' do
      get '/basic/doc/0.1'

      last_response.status.should eq(200)
    end

    context 'when no format' do
      it 'sets a html content type' do
        get '/basic/doc/0.1'

        last_response.header['Content-Type'].should eq('text/html')
      end
    end

    context 'when json format' do
      it 'sets a json content type' do
        get '/basic/doc/0.1?format=json'

        last_response.header['Content-Type'].should eq('application/json')
      end
    end

  end

  describe 'an operation url' do

    it 'responds to /basic/api/0.1/users' do
      get '/basic/api/0.1/users'

      last_response.status.should eq(200)
    end

    it 'sets a json content type' do
      get '/basic/api/0.1/users'

      last_response.header['Content-Type'].should eq('application/json')
    end

  end

end