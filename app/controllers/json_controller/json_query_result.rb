# typed: true
# frozen_string_literal: true

class JsonController
  class JsonQueryResult

    # Uses the parameter object to construct a query and return the result.
    #
    # @param parameters [Hash] the parameters object
    # @return JSON for the results of the query
    def self.create_from(parameters)
      raise StandardError.new('Bad parameters: No model name given') unless parameters[:model]

      model = get_model(model: parameters[:model], include: parameters[:include])
      result = apply_method(model: model, method: parameters[:method], arguments: parameters[:arguments], id: parameters[:id], options: parameters[:options])

      return result.as_json(include: parameters[:include], methods: parameters[:methods]) if parameters[:methods] && parameters[:include]
      return result.as_json(methods: parameters[:methods]) if parameters[:methods] && !parameters[:include]
      return result.as_json(include: parameters[:include]) if !parameters[:methods] && parameters[:include]

      result.as_json
    end

    # private method definitions

    # Gets the model object for the query by finding the model class and
    # then applying the specified includes.
    #
    # @param model [String] the name of the model class
    # @param include [Array, Hash, String] the include specification
    def self.get_model(model:, include:)
      model = Object.const_get(model)
      return model unless include

      include_object = gather_includes(model: model, value: include)
      return model unless include_object

      model.includes(include_object)
    end

    # Gathers the include object specified by the value.
    # Converts strings and keys to symbols.
    # But excludes symbols that don't represent an association for the model.
    #
    # @param model [ActiveModel] the model object
    # @param value [Array, Hash, String] the include specification
    # @return the include specification with symbolized strings and non-associations excluded
    def self.gather_includes(model:, value:)
      if value.is_a?(String)
        return value.to_sym if association?(model: model, name: value)

        value_symbol = value.to_sym
        raise "Invalid include: #{value}" unless model.method_defined?(value_symbol)
      end

      return value.collect { |element| gather_includes(model: model, value: element) } if value.is_a?(Array)

      if value.is_a?(Hash)
        include_hash = {}
        value.each do |key, v|
          next unless association?(model: model, name: key)

          include_hash[key.to_sym] = gather_includes(model: model, value: v)
        end
        return include_hash
      end

      nil
    end

    # Applies the specified method of the model to the arguments or id.
    # Also, applies the options to any where queries.
    #
    # @param model [ActiveModel]
    # @param method [String] the name of the method
    # @param arguments [String] the arguments to the method
    # @param id [Number] the ID for find method
    # @param options: [Hash] the hash with options for the query
    # @return [ActiveRecord] record created by the query
    def self.apply_method(model:, method:, arguments:, id:, options:)
      raise 'Query method expected' unless method_ok?(method) || id
      return model.find(id) if id
      return model.send(method, *arguments) if method != 'where'

      result = model.where(arguments)
      return result unless options

      result = result.limit(options[:limit]) if options[:limit] && options[:limit].to_i.positive?
      result = result.offset(options[:offset]) if options[:offset] && options[:offset].to_i.positive?
      result = result.order('created_at DESC') if options[:reverse]
      result
    end

    # Indicates whether the model has an association with the name.
    #
    # @param model [Object] the model object
    # @param name [String] the name to test
    def self.association?(model:, name:)
      model.reflections.key?(name)
    end

    # Indicates whether the method is valid for a query.
    #
    # @param m [String] the name of the method
    # @return [Boolean] true if the name is a valid query method
    def self.method_ok?(name)
      return false unless name
      raise "Illegal method #{name} requested from front end." unless %w[all where find find_by_name new].member?(name)

      true
    end

    private_class_method :apply_method, :gather_includes, :association?, :method_ok?
  end
end
