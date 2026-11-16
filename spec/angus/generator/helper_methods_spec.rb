require 'spec_helper'
require 'angus/generator/thor/helper_methods'

RSpec.describe Angus::HelperMethods do
  let(:test_class) { Class.new { include Angus::HelperMethods }.new }

  describe '#pluralize' do
    it 'pluralizes regular words' do
      expect(test_class.pluralize('user')).to eq('users')
      expect(test_class.pluralize('book')).to eq('books')
      expect(test_class.pluralize('car')).to eq('cars')
    end

    it 'handles irregular plurals' do
      expect(test_class.pluralize('person')).to eq('people')
      expect(test_class.pluralize('man')).to eq('men')
      expect(test_class.pluralize('child')).to eq('children')
    end

    it 'handles words ending in s, x, ch, sh' do
      expect(test_class.pluralize('bus')).to eq('buses')
      expect(test_class.pluralize('box')).to eq('boxes')
      expect(test_class.pluralize('church')).to eq('churches')
      expect(test_class.pluralize('dish')).to eq('dishes')
    end

    it 'handles words ending in y' do
      expect(test_class.pluralize('city')).to eq('cities')
      expect(test_class.pluralize('baby')).to eq('babies')
    end

    it 'handles uncountable words' do
      expect(test_class.pluralize('equipment')).to eq('equipment')
      expect(test_class.pluralize('information')).to eq('information')
      expect(test_class.pluralize('rice')).to eq('rice')
    end

    it 'handles empty strings' do
      expect(test_class.pluralize('')).to eq('')
    end

    it 'handles nil' do
      expect(test_class.pluralize(nil)).to eq('')
    end
  end

  describe '#classify' do
    it 'converts snake_case to CamelCase' do
      expect(test_class.classify('user')).to eq('User')
      expect(test_class.classify('user_profile')).to eq('UserProfile')
      expect(test_class.classify('admin_user')).to eq('AdminUser')
    end

    it 'handles namespaced names' do
      expect(test_class.classify('api/user')).to eq('Api::User')
      expect(test_class.classify('v1/api/client')).to eq('V1::Api::Client')
    end

    it 'handles strings with numbers' do
      expect(test_class.classify('user2profile')).to eq('User2profile')
      expect(test_class.classify('api2_client')).to eq('Api2Client')
    end
  end

  describe '#underscore' do
    it 'converts CamelCase to snake_case' do
      expect(test_class.underscore('User')).to eq('user')
      expect(test_class.underscore('UserProfile')).to eq('user_profile')
      expect(test_class.underscore('AdminUser')).to eq('admin_user')
    end

    it 'handles namespaced names' do
      expect(test_class.underscore('Api::User')).to eq('api/user')
      expect(test_class.underscore('V1::Api::Client')).to eq('v1/api/client')
    end

    it 'handles strings with numbers' do
      expect(test_class.underscore('User2Profile')).to eq('user2_profile')
      expect(test_class.underscore('API2Client')).to eq('api2_client')
    end

    it 'handles strings with hyphens' do
      expect(test_class.underscore('user-profile')).to eq('user_profile')
      expect(test_class.underscore('admin-user-profile')).to eq('admin_user_profile')
    end

    it 'handles empty strings' do
      expect(test_class.underscore('')).to eq('')
    end
  end
end