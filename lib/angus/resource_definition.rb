require 'yaml'

module Angus
  class ResourceDefinition

    def initialize(resource_name, representations)
      @resource_name       = resource_name
      @resource_class_name = classify_resource(resource_name)
      @representations     = representations || {}
    end

    def operations
      @representations.operations[@resource_name.to_s] || []
    end

    def canonical_name
      Angus::String.underscore(@resource_class_name.to_s)
    end

    def resource_class
      return @resource_class if @resource_class
      require resource_path

      @resource_class = Object.const_get(@resource_class_name)
    end

    def resource_path
      File.join('resources', canonical_name)
    end

    def build_response_metadata(response_representation)
      return {} unless response_representation

      case response_representation
        when Angus::SDoc::Definitions::Representation
          result = []

          response_representation.fields.each do |field|
            result << build_response_metadata(field)
          end

          result
        when Array
          result = []

          response_representation.each do |field|
            result << build_response_metadata(field)
          end

          result
        else
          field_name = response_representation.name
          field_type = response_representation.type || response_representation.elements_type

          # TODO fix this
          representation = representation_by_name(field_type)

          if representation.nil?
            field_name.to_sym
          else
            {field_name.to_sym => build_response_metadata(representation)}
          end
      end
    end

    # TODO improve this find
    def representation_by_name(name)
      @representations.representations.find { |representation| representation.name == name }
    end

    private

    def classify_resource(resource)
      Angus::String.camelize(resource)
    end

  end
end