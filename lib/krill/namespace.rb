# typed: false
# frozen_string_literal: true

module Krill
  module Namespace
    def needs(path)
      parts = path.split('/')
      raise "needs called with improper path. Should be of the form: 'Category/Name'" if parts.length != 2

      libs = Library.where(name: parts[1], category: parts[0])
      raise "could not find library '#{path}'" if libs.empty?

      add(code: libs[0].source, source_name: path)
    end

    def add(code:, source_name: '(eval)')
      class_eval(code.content, source_name)
    end
  end

  def self.make_namespace(code: nil, name: 'ExecutionNamespace', source_name: '(eval)')
    namespace = Object.const_set(name, Module.new)
    namespace.extend(Namespace)
    namespace.add(code: code, source_name: source_name) unless code.nil?

    namespace
  end

  def self.get_arguments(code)
    namespace = make_namespace(code)
    p = namespace::Protocol.new

    if p.respond_to?(:arguments)
      p.arguments
    else
      {}
    end
  end

end
