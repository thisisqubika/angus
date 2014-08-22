require 'yaml'

module Angus
  class BaseResource

    def self.inherited(subclass)
      self._before_filers.each { |before_filer| subclass._before_filers << before_filer }
      self._after_filers.each { |after_filer| subclass._after_filers << after_filer }
    end

    attr_reader :request, :params, :operation

    def initialize(request, params, operation)
      @request   = request
      @params    = params
      @operation = operation
    end

    def run_validations!
      ParamsValidator.new(@operation).valid?(@params)
    end

    def run_before_filters
      self.class._before_filers.each { |before_filer| run_filter(before_filer) }
    end

    def run_after_filters(response = nil)
      self.class._after_filers.each { |after_filer| run_filter(after_filer, response) }
    end

    def self.before(method_names = [], options = {}, &block)
      self._before_filers.concat(validate_and_build_filters(method_names, options, block))
    end

    def self.after(method_names = [], options = {}, &block)
      self._after_filers.concat(validate_and_build_filters(method_names, options, block))
    end

    def self._before_filers
      @_before_filers ||= []
    end

    def self._after_filers
      @_after_filers ||= []
    end

    def self.validate_and_build_filters(method_names, options, block)
      if method_names.is_a?(Hash) && options.empty?
        options = method_names
        method_names = []
      else
        method_names = Array(method_names)
      end

      if (method_names.any? && block) || (method_names.empty? && !block)
        raise 'InvalidFilterDefinition'
      end

      if method_names.any?
        method_names.inject([]) do |filters, method_name|
          filters << { :filter => method_name, :options => options }
        end
      else
        [{ :filter => Proc.new { |resource| block.call(resource) }, :options => options }]
      end
    end
    private_class_method :validate_and_build_filters

    private

    def run_filter(filer_definition, *args)
      return unless run_filter?(self.operation, filer_definition[:options])

      if filer_definition[:filter].is_a?(Symbol)
        send(filer_definition[:filter], *args)
      else
        if args.any?
          filer_definition[:filter].call([self, *args])
        else
          filer_definition[:filter].call(self)
        end
      end
    end

    def run_filter?(operation, filer_options)
      if filer_options[:only]
        Array(filer_options[:only]).include?(operation.code_name.to_sym)
      elsif filer_options[:except]
        !Array(filer_options[:except]).include?(operation.code_name.to_sym)
      else
        true
      end
    end

  end
end