require 'spec_helper'

require 'angus/base_proxy'
require 'angus/middleware/exception_handler'

work_dir =  File.join(File.dirname(__FILE__), '..', '..', 'functional', 'basic')
describe Angus::Middleware::ExceptionHandler, { :work_dir => work_dir } do

  let(:request_handler) {
    double(:request_handler, call: double(:app))
  }

  let(:definition_block) {
    double(:definition_handler, call: nil)
  }

  let(:base_proxy) {
    Angus::BaseProxy.new(request_handler, definition_block)
  }

  let(:app) {
    double(:app, :call => app_response,
                 :base_middleware => base_proxy) }

  let(:app_response) { :ok }

  let(:env) { :env }

  subject(:middleware) { Angus::Middleware::ExceptionHandler.new(app) }

  it 'returns app response' do
    middleware.call(env).should eq(app_response)
  end

  context 'when unknown error' do
    before { app.stub(:call).with(any_args).and_raise(Exception) }

    it 'returns INTERNAL SERVER ERROR' do
      response = middleware.call(env)

      response.first.should eq(Angus::StatusCodes::HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR)
    end
  end

  context 'when #errors' do

    let(:error) { Exception.new }

    before do
      error.stub(:errors => [:errors])
      app.stub(:call).with(any_args).and_raise(error)
    end

    it 'returns HTTP_STATUS_CODE_CONFLICT ERROR' do
      response = middleware.call(env)

      response.first.should eq(Angus::StatusCodes::HTTP_STATUS_CODE_CONFLICT)
    end
  end

  context 'when known error' do
    let(:know_error) { UserNotFound = Class.new(StandardError) }

    before { app.stub(:call).with(any_args).and_raise(know_error.new) }

    it 'returns the status code set for the error' do
      response = middleware.call(env)

      response.first.should eq(Angus::StatusCodes::HTTP_STATUS_CODE_NOT_FOUND)
    end
  end

end