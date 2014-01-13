require 'spec_helper'

require 'rack/test'

require 'functional/basic/services/basic'

describe Spec::Functional::Basic, { :work_dir => "#{File.dirname(__FILE__ )}/basic" } do
  include Rack::Test::Methods

  subject(:app) { Rack::Lint.new(Spec::Functional::Basic.new) }

  it 'responds to /' do
    get '/'

    last_response.status.should eq(200)
    last_response.header['Content-Type'].should eq('application/json')
  end

  it 'responds to /' do
    get '/basic'

    last_response.status.should eq(200)
    last_response.header['Content-Type'].should eq('application/json')
  end

  describe 'the documentation url' do

    it 'responds to /basic/doc/0.1' do
      get '/basic/doc/0.1'

      last_response.status.should eq(200)
    end

    context 'when no format' do
      it 'sets an html content type' do
        get '/basic/doc/0.1'

        last_response.header['Content-Type'].should eq('text/html;charset=utf-8')
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

    context 'when an expected error happens' do
      it 'sets the correct status code' do
        get '/basic/api/0.1/users/-1'

        last_response.status.should eq(404)
      end

      it 'sets a json content type' do
        get '/basic/api/0.1/users/-1'

        last_response.header['Content-Type'].should eq('application/json')
      end

      describe 'the response body' do
        subject(:body) {
          get '/basic/api/0.1/users/-1'
          JSON(last_response.body)
        }

        its(['status']) { should eq('error')}
        its(['messages']) { should include({ 'level' => 'error', 'key' => 'UserNotFound',
                                             'dsc' => 'User with id=-1 not found' })}
      end
    end

    context 'when an attribute is missing from the response' do
      it 'sets the correct status code' do
        get '/basic/api/0.1/users/3'

        last_response.status.should eq(500)
      end

      it 'sets a json content type' do
        get '/basic/api/0.1/users/3'

        last_response.header['Content-Type'].should eq('application/json')
      end

      describe 'the response body' do
        subject(:body) {
          get '/basic/api/0.1/users/3'
          JSON(last_response.body)
        }

        its(['status']) { should eq('error')}
        its(['messages']) { should include({ 'level' => 'error', 'key' => 'Angus::Marshalling::InvalidGetterError',
                                             'dsc' => 'The requested getter (name) does not exist. ' })}
      end
    end

    context 'when a message is returned' do
      context 'when the message has a given text' do
        it 'sets the correct status code' do
          post '/basic/api/0.1/users'

          last_response.status.should eq(200)
        end

        it 'sets a json content type' do
          post '/basic/api/0.1/users'

          last_response.header['Content-Type'].should eq('application/json')
        end

        describe 'the response body' do
          subject(:body) {
            post'/basic/api/0.1/users'
            JSON(last_response.body)
          }

          its(['status']) { should eq('success')}
          its(['messages']) { should include({ 'level' => 'info', 'key' => 'UserCreatedSuccessfully',
                                               'dsc' => 'The User has been created successfully.' })}
        end
      end

      context 'when a message does not have a given text' do
        it 'sets the correct status code' do
          delete '/basic/api/0.1/users/1'

          last_response.status.should eq(200)
        end

        it 'sets a json content type' do
          delete '/basic/api/0.1/users/1'

          last_response.header['Content-Type'].should eq('application/json')
        end

        describe 'the response body' do
          subject(:body) {
            delete '/basic/api/0.1/users/1'
            JSON(last_response.body)
          }

          its(['status']) { should eq('success')}
          its(['messages']) { should include({ 'level' => 'info', 'key' => 'UserDeletedSuccessfully',
                                               'dsc' => 'The User has been deleted successfully.' })}
        end
      end

      context 'when an inexistent message is returned' do
        it 'sets the correct status code' do
          delete '/basic/api/0.1/users/2'

          last_response.status.should eq(500)
        end

        it 'sets a json content type' do
          delete '/basic/api/0.1/users/2'

          last_response.header['Content-Type'].should eq('application/json')
        end

        describe 'the response body' do
          subject(:body) {
            delete '/basic/api/0.1/users/2'
            JSON(last_response.body)
          }

          its(['status']) { should eq('error')}
          its(['messages']) { should include({ 'level' => 'error', 'key' => 'NameError',
                                               'dsc' => 'Could not found message with key: UserAlreadyDeleted, level: info' })}
        end
      end
    end

  end

end