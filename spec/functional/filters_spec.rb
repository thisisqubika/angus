require 'spec_helper'
require 'rack/test'
require 'functional/filters/services/filters'

require 'functional/filters/resources/users'

working_dir = "#{File.dirname(__FILE__ )}/filters"

describe Spec::Functional::Filters, { :work_dir => working_dir } do
  include Rack::Test::Methods

  subject(:app) { Rack::Lint.new(Spec::Functional::Filters.new) }

  context 'when a before filter method is set' do
    it 'invokes the given method' do
      Users.any_instance.should_receive(:before_filter_method)

      get '/filters/api/0.1/users'
    end

    context 'when the filter is excluded for the action' do
      it 'does not invoke the given method' do
        Users.any_instance.should_not_receive(:before_filter_method)

        get '/filters/api/0.1/users/1'
      end
    end

    context 'when the filter only applies for the some actions' do
      it 'does not invoke the given method for the excluded actions' do
        Users.any_instance.should_not_receive(:after_filter_method)

        post '/filters/api/0.1/users'
      end

      it 'invokes the given method for the included actions' do
        Users.any_instance.should_receive(:after_filter_method)

        get '/filters/api/0.1/users'
      end
    end
  end

  context 'when a before filter block is set' do
    it 'executes the given block' do
      Users.any_instance.should_receive(:before_filter_block)

      get '/filters/api/0.1/users'
    end
  end

  context 'when a after filter method is set' do
    it 'invokes the given method' do
      Users.any_instance.should_receive(:after_filter_method)

      get '/filters/api/0.1/users'
    end
  end

  context 'when a after filter block is set' do
    it 'executes the given block' do
      Users.any_instance.should_receive(:after_filter_block)

      get '/filters/api/0.1/users'
    end
  end

  context 'when the operation fails' do
    it 'invokes the the after filter anyway' do
      Users.any_instance.should_receive(:after_filter_method)

      get '/filters/api/0.1/users/1'
    end
  end
end