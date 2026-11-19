require 'spec_helper'
require 'rack/test'
require 'functional/basic/services/basic'

describe Spec::Functional::Basic, work_dir: "#{File.dirname(__FILE__)}/basic" do
  include Rack::Test::Methods

  subject(:app) { Rack::Lint.new(Spec::Functional::Basic.new) }

  it 'responds to /' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.header['Content-Type']).to eq('application/json')
  end

  it 'responds to /basic' do
    get '/basic'

    expect(last_response.status).to eq(200)
    expect(last_response.header['Content-Type']).to eq('application/json')
  end

  describe 'the documentation url' do
    it 'responds to /basic/doc/0.1' do
      get '/basic/doc/0.1'
      expect(last_response.status).to eq(200)
    end

    context 'when no format' do
      it 'sets an html content type' do
        get '/basic/doc/0.1'
        expect(last_response.header['Content-Type']).to eq('text/html;charset=utf-8')
      end
    end

    context 'when json format' do
      it 'sets a json content type' do
        get '/basic/doc/0.1?format=json'
        expect(last_response.header['Content-Type']).to eq('application/json')
      end
    end
  end

  describe 'an operation url' do
    it 'responds to /basic/api/0.1/users' do
      get '/basic/api/0.1/users'
      expect(last_response.status).to eq(200)
    end

    it 'sets a json content type' do
      get '/basic/api/0.1/users'
      expect(last_response.header['Content-Type']).to eq('application/json')
    end

    context 'when an expected error happens' do
      it 'sets the correct status code' do
        get '/basic/api/0.1/users/-1'
        expect(last_response.status).to eq(404)
      end

      it 'sets a json content type' do
        get '/basic/api/0.1/users/-1'
        expect(last_response.header['Content-Type']).to eq('application/json')
      end

      describe 'the response body' do
        subject(:body) do
          get '/basic/api/0.1/users/-1'
          JSON.parse(last_response.body)
        end

        it 'has error status' do
          expect(body['status']).to eq('error')
        end

        it 'includes UserNotFound message' do
          expect(body['messages']).to include(
            { 'level' => 'error', 'key' => 'UserNotFound', 'dsc' => 'User with id=-1 not found' }
          )
        end
      end
    end

    context 'when an attribute is missing from the response' do
      it 'sets the correct status code' do
        get '/basic/api/0.1/users/3'
        expect(last_response.status).to eq(500)
      end

      it 'sets a json content type' do
        get '/basic/api/0.1/users/3'
        expect(last_response.header['Content-Type']).to eq('application/json')
      end

      describe 'the response body' do
        subject(:body) do
          get '/basic/api/0.1/users/3'
          JSON.parse(last_response.body)
        end

        it 'has error status' do
          expect(body['status']).to eq('error')
        end

        it 'includes InvalidGetterError message' do
          expect(body['messages']).to include(
            {
              'level' => 'error',
              'key'   => 'Angus::Marshalling::InvalidGetterError',
              'dsc'   => 'The requested getter (name) does not exist. '
            }
          )
        end
      end
    end

    context 'when a message is returned' do
      context 'when the message has a given text' do
        it 'sets the correct status code' do
          post '/basic/api/0.1/users'
          expect(last_response.status).to eq(200)
        end

        it 'sets a json content type' do
          post '/basic/api/0.1/users'
          expect(last_response.header['Content-Type']).to eq('application/json')
        end

        describe 'the response body' do
          subject(:body) do
            post '/basic/api/0.1/users'
            JSON.parse(last_response.body)
          end

          it 'has success status' do
            expect(body['status']).to eq('success')
          end

          it 'includes UserCreatedSuccessfully message' do
            expect(body['messages']).to include(
              {
                'level' => 'info',
                'key'   => 'UserCreatedSuccessfully',
                'dsc'   => 'The User has been created successfully.'
              }
            )
          end
        end
      end

      context 'when a message does not have a given text' do
        it 'sets the correct status code' do
          delete '/basic/api/0.1/users/1'
          expect(last_response.status).to eq(200)
        end

        it 'sets a json content type' do
          delete '/basic/api/0.1/users/1'
          expect(last_response.header['Content-Type']).to eq('application/json')
        end

        describe 'the response body' do
          subject(:body) do
            delete '/basic/api/0.1/users/1'
            JSON.parse(last_response.body)
          end

          it 'has success status' do
            expect(body['status']).to eq('success')
          end

          it 'includes UserDeletedSuccessfully message' do
            expect(body['messages']).to include(
              {
                'level' => 'info',
                'key'   => 'UserDeletedSuccessfully',
                'dsc'   => 'The User has been deleted successfully.'
              }
            )
          end
        end
      end

      context 'when an inexistent message is returned' do
        it 'sets the correct status code' do
          delete '/basic/api/0.1/users/2'
          expect(last_response.status).to eq(500)
        end

        it 'sets a json content type' do
          delete '/basic/api/0.1/users/2'
          expect(last_response.header['Content-Type']).to eq('application/json')
        end

        describe 'the response body' do
          subject(:body) do
            delete '/basic/api/0.1/users/2'
            JSON.parse(last_response.body)
          end

          it 'has error status' do
            expect(body['status']).to eq('error')
          end

          it 'includes NameError message (stable across Ruby versions)' do
            expected_prefix = 'Could not found message with key: UserAlreadyDeleted, level: info'

            expect(body['messages']).to include(
              hash_including(
                'level' => 'error',
                'key'   => 'NameError',
                'dsc'   => a_string_starting_with(expected_prefix)
              )
            )
          end
        end
      end
    end
  end
end
