require 'spec_helper'

require 'angus/request_handler'

work_dir =  File.join(File.dirname(__FILE__), '..', 'functional', 'basic')
describe Angus::RequestHandler, { :work_dir => work_dir } do

  subject(:handler) { Angus::RequestHandler.new }

  let(:app) { double(:app) }

  describe '.new' do
    it 'has a a exception handler middleware' do
      handler.middleware.map(&:first).should include(Angus::Middleware::ExceptionHandler)
    end
  end

  describe '#use' do

    let(:other_middleware) { Struct.new(:app) }

    it 'adds the given middleware after the rest' do
      handler.use(other_middleware)

      handler.middleware.last.first.should eq(other_middleware)
    end

    context 'when the given middleware is already present' do
      before { handler.use(other_middleware) }

      it 'does not modify the middleware' do
        expect {
          handler.use(other_middleware)
        }.to_not change { handler.middleware }
      end
    end

  end

  describe '#use_after' do

    let(:other_middleware) { Struct.new(:app) }

    it 'adds the given middleware after the given class' do
      handler.use_after(Angus::Middleware::ExceptionHandler, other_middleware)

      handler.middleware.last.first.should eq(other_middleware)
    end

    context 'when the given class is not present in the middleware' do
      it 'raises an MiddlewareNotFound error' do
        expect {
          handler.use_after(Angus::Middleware, other_middleware)
        }.to raise_error(MiddlewareNotFound)
      end
    end

    context 'when the given middleware is already present' do
      before { handler.use_after(Angus::Middleware::ExceptionHandler, other_middleware) }

      it 'does not modify the middleware' do
        expect {
          handler.use_after(Angus::Middleware::ExceptionHandler, other_middleware)
        }.to_not change { handler.middleware }
      end
    end

  end

  describe '#use_before' do

    let(:other_middleware) { Struct.new(:app) }

    it 'adds the given middleware before the given class' do
      handler.use_before(Angus::Middleware::ExceptionHandler, other_middleware)

      handler.middleware.first.first.should eq(other_middleware)
    end

    context 'when the given class is not present in the middleware' do
      it 'raises an MiddlewareNotFound error' do
        expect {
          handler.use_before(Angus::Middleware, other_middleware)
        }.to raise_error(MiddlewareNotFound)
      end
    end

    context 'when the given middleware is already present' do
     before { handler.use_before(Angus::Middleware::ExceptionHandler, other_middleware) }

      it 'does not modify the middleware' do
        expect {
          handler.use_before(Angus::Middleware::ExceptionHandler, other_middleware)
        }.to_not change { handler.middleware }
      end
    end

  end

  describe '#disuse' do

    let(:other_middleware) { Struct.new(:app) }

    it 'removes the given class from the middleware' do
      handler.disuse(Angus::Middleware::ExceptionHandler)

      handler.middleware.map(&:first).should_not include(Angus::Middleware::ExceptionHandler)
    end

    it 'removes only given class from the middleware' do
      handler.use(other_middleware)

      handler.disuse(Angus::Middleware::ExceptionHandler)

      handler.middleware.map(&:first).should_not include(Angus::Middleware::ExceptionHandler)
      handler.middleware.map(&:first).should include(other_middleware)
    end

    context 'when the given class is not present in the middleware' do
      it 'raises an MiddlewareNotFound error' do
        expect {
          handler.disuse(Angus::Middleware)
        }.to raise_error(MiddlewareNotFound)
      end
    end

  end

end