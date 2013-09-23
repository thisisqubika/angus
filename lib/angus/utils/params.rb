module Angus
  module Params

    # Enable string or symbol key access to the nested params hash.
    def self.indifferent_params(object)
      case object
        when Hash
          new_hash = indifferent_hash
          object.each { |key, value| new_hash[key] = indifferent_params(value) }
          new_hash
        when Array
          object.map { |item| indifferent_params(item) }
        else
          object
      end
    end

    # Creates a Hash with indifferent access.
    def self.indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end

  end
end