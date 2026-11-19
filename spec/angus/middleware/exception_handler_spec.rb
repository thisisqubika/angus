require 'spec_helper'

require 'angus/base_proxy'
require 'angus/middleware/exception_handler'

work_dir = File.join(File.dirname(__FILE__), '..', '..', 'functional', 'basic')

describe Angus::Middleware::ExceptionHandler, work_dir: work_dir do
  let(:request_handler) do
    double(:request_handler, call: double(:app))
  end

  let(:definition_block) do
    double(:definition_handler, call: nil)
  end

  let(:base_proxy) do
    Angus::BaseProxy.new(request_handler, definition_block)
  end

  let(:app_response) { :ok }

  let(:app) do
    double(
      :app,
      call: app_response,
      base_middleware: base_proxy
    )
  end

  let(:env) { :env }

  subject(:middleware) { described_class.new(app) }

  it 'returns app response' do
    expect(middleware.call(env)).to eq(app_response)
  end

  context 'when unknown error' do
    before do
      allow(app).to receive(:call).with(any_args).and_raise(StandardError)
    end

    it 'returns INTERNAL SERVER ERROR' do
      response = middleware.call(env)

      expect(response.first).to eq(
        Angus::StatusCodes::HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR
      )
    end
  end

  context 'when #errors' do
    let(:error) { StandardError.new }

    before do
      allow(error).to receive(:errors).and_return([:errors])
      allow(app).to receive(:call).with(any_args).and_raise(error)
    end

    it 'returns HTTP_STATUS_CODE_CONFLICT ERROR' do
      response = middleware.call(env)

      expect(response.first).to eq(
        Angus::StatusCodes::HTTP_STATUS_CODE_CONFLICT
      )
    end
  end

  context 'when known error' do
    let(:known_error_class) { stub_const('UserNotFound', Class.new(StandardError)) }

    before do
      allow(app).to receive(:call).with(any_args).and_raise(known_error_class.new)
    end

    it 'returns the status code set for the error' do
      response = middleware.call(env)

      expect(response.first).to eq(
        Angus::StatusCodes::HTTP_STATUS_CODE_NOT_FOUND
      )
    end
  end
end
