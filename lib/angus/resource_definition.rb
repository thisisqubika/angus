require 'yaml'

module Angus
  class ResourceDefinition
    def initialize(root_path, resource_name, representations)
      @root_path            = root_path
      @resource_name        = resource_name
      @resource_class_name  = classify_resource(resource_name)
      @representations      = representations || {}
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
      resource_path = File.join('resources', canonical_name)

      if @root_path.empty?
        resource_path
      else
        File.join(@root_path, resource_path)
      end
    end

    def build_response_metadata(response_representation, optional_fields = [], parent_name = nil)
      return {} unless response_representation

      case response_representation
      when Angus::SDoc::Definitions::Representation
        result = []

        response_representation.fields.each do |field|
          result << build_response_metadata(field, optional_fields, parent_name)
        end

        result << { optional_fields: optional_fields }
      when Array
        result = []

        response_representation.each do |field|
          result << build_response_metadata(field, optional_fields, parent_name)
        end

        result << { optional_fields: optional_fields }
      else
        field_name = response_representation.name
        field_type_name = response_representation.type || response_representation.elements_type
        field_optional = response_representation.optional

        if field_optional
          optional_fields << if parent_name
                               "#{parent_name}.#{field_name}"
                             else
                               field_name
                             end
        end

        representation = representation_by_name(field_type_name)

        if representation.nil?
          field_name.to_sym
        else
          if parent_name
            parent_name.concat(".#{field_name}")
          else
            parent_name = field_name
          end

          {
            field_name.to_sym => build_response_metadata(representation, optional_fields, parent_name)
          }
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
