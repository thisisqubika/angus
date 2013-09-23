require 'bigdecimal'
require 'date'

module Angus
  module Unmarshalling

    def self.unmarshal_scalar(scalar, type)
      return nil if scalar.nil?

      case type
      when :string
        scalar
      when :integer
        scalar
      when :boolean
        scalar
      when :date
        Date.iso8601(scalar)
      when :date_time
        DateTime.iso8601(scalar)
      when :decimal
        BigDecimal.new(scalar.to_s)
      else
        raise ArgumentError, "Unknown type: #{type}"
      end
    end

  end
end
