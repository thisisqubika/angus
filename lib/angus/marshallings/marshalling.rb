require 'bigdecimal'
require 'date'

module Angus
  module Marshalling

    # Marshal a complex object.
    #
    # @param object The object to be marshalled
    # @param getters An array of getters / hashes that will be used to obtain the information
    #   from the object.
    def self.marshal_object(object, getters)
      result = {}
      getters.each do |getter|
        next if getter.is_a?(Hash) && getter.key?(:optional_fields)

        if getter.is_a?(Hash)
          key = getter.keys[0]
          value = get_value(object, key)

          #HACK to support ActiveRecord::Relation
          if defined?(ActiveRecord::Relation) && value.is_a?(ActiveRecord::Relation)
            value = value.to_a
          end

          if value.is_a?(Array)
            result[key] = value.map { |object| marshal_object(object, getter.values[0]) }
          else
            result[key] = value.nil? ? nil : marshal_object(value, getter.values[0])
          end
        else
          value = get_value(object, getter)
          result[getter] = marshal_scalar(value)
        end
      end
      return result
    end

    private

    # Gets a value from a object for a given getter.
    #
    # @param [Object] object The object to get the value from
    # @param [Symbol, String] getter to request from the object
    # @raise [InvalidGetterError] when getter is not present in the object
    #
    # @return [Object] the requested value
    def self.get_value(object, getter)
      if object.is_a?(Hash)
        get_value_from_hash(object, getter)
      else
        get_value_from_object(object, getter)
      end
    end

    # Gets a value from a object by invoking method.
    #
    # @param [Object] object The object to get the value from
    # @param [Symbol, String] method the method to invoke in the object
    #
    # @raise [InvalidGetterError] when the object does not responds to method as public.
    #
    # @return [Object] the requested value
    def self.get_value_from_object(object, method)
      value = object.public_send method.to_sym

      # HACK in order to fix the error:
      # NoMethodError: undefined method `merge' for #<JSON::Ext::Generator::State:0x257fd086>
      if value.is_a?(Array)
        value.to_a
      else
        value
      end
    rescue NoMethodError => error
      raise Marshalling::InvalidGetterError.new(method, error.backtrace.first)
    end

    # Gets a value from a hash for a given key.
    #
    # It accepts the key as a symbol or a string,
    # it looks for the symbol key first.
    #
    # @param [Hash] hash The hash to get the value from
    # @param [Symbol, String] key to get from the hash
    # @raise [InvalidGetterError] when the key does not
    # exists in the hash
    # @return [Object] the requested value
    def self.get_value_from_hash(hash, key)
      if hash.has_key?(key.to_sym)
        hash[key.to_sym]
      elsif hash.has_key?(key.to_s)
        hash[key.to_s]
      else
        raise Marshalling::InvalidGetterError.new(key)
      end
    end

    # Marshal a scalar value
    # @param scalar the scalar value to be marshalled
    #
    # If scalar is a Date or DateTime it return a iso8601 string
    # If scalar is a Symbol it returns the symbol as string
    # Everything else (string, integer, ...) returns the same object.
    def self.marshal_scalar(scalar)
      case scalar
        when Time
          scalar.iso8601
        when DateTime
          scalar.iso8601
        when Date
          scalar.iso8601
        when Symbol
          scalar.to_s
        else
          scalar
      end
    end

  end
end
