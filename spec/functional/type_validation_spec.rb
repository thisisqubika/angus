require 'spec_helper'
require 'rack/test'
require 'functional/type_validation/services/type_validation'

working_dir = "#{File.dirname(__FILE__ )}/type_validation"

describe Spec::Functional::TypeValidation, { :work_dir => working_dir } do
  include Rack::Test::Methods

  subject(:app) { Rack::Lint.new(Spec::Functional::TypeValidation.new) }

  describe 'required fields validation' do
    it 'responds correctly if all required fields are given' do
      get '/type_validation/api/0.1/admins?requester_id=1'

      response = JSON(last_response.body)

      expect(response['status']).to eq('success')
    end

    it 'responds with an error when a required field is not present' do
      get '/type_validation/api/0.1/admins'

      expect(last_response).to have_error_response
      expect(last_response).to have_in_message({
        'level' => 'error',
        'key'   => 'TODO define',
        'dsc'   => 'requester_id'
      })
    end
  end

  describe 'type fields validation' do
    let(:valid_params) {
      {
        'name'              => 'Britney Watson',
        'age'               => 22,
        'favorite_decimal'  => 21.3,
        'birth_date'        => Date.today.iso8601,
        'last_signed_in_at' => DateTime.now.iso8601
      }
    }

    context 'string type' do
      it 'should be valid if a number is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'name' => 22
        })

        expect(last_response).to have_success_response
      end

      it 'should be valid if a text is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'name' => 'Example Text'
        })

        expect(last_response).to have_success_response
      end

      it 'should be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'name' => Date.today
        })

        expect(last_response).to have_success_response
      end
    end

    context 'integer type' do
      it 'should be valid if a number is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'age' => 22
        })

        expect(last_response).to have_success_response
      end

      it 'should not be valid if a decimal is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'age' => 22.1
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a text is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'age' => 'Example Text'
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'age' => Date.today
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end
    end

    context 'decimal type' do
      it 'should be valid if a number is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'favorite_decimal' => 22
        })

        expect(last_response).to have_success_response
      end

      it 'should be valid if a decimal is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'favorite_decimal' => 22.1
        })

        expect(last_response).to have_success_response
      end

      it 'should not be valid if a text is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'favorite_decimal' => 'Example Text'
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'favorite_decimal' => Date.today
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end
    end

    context 'date type' do
      it 'should be valid if a number is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'birth_date' => 22
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should be valid if a decimal is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'birth_date' => 22.1
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a text is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'birth_date' => 'Example Text'
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'birth_date' => Date.today.iso8601
        })

        expect(last_response).to have_success_response
      end

      it 'should not be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'birth_date' => DateTime.now.iso8601
        })

        expect(last_response).to have_success_response
      end
    end

    context 'datetime type' do
      it 'should be valid if a number is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'last_signed_in_at' => 22
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should be valid if a decimal is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'last_signed_in_at' => 22.1
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a text is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'last_signed_in_at' => 'Example Text'
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'last_signed_in_at' => Date.today.iso8601
        })

        expect(last_response).to have_error_response
        expect(last_response).to have_in_message({
          'level' => 'error',
          'key'   => 'TODO define',
          'dsc'   => 'TODO define'
        })
      end

      it 'should not be valid if a date is given' do
        post '/type_validation/api/0.1/admins', valid_params.merge({
          'last_signed_in_at' => DateTime.now.iso8601
        })

        expect(last_response).to have_success_response
      end
    end
  end

end