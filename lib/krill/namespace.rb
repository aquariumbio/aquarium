# frozen_string_literal: true

module Krill
  module Namespace
    def needs(path)
      parts = path.split('/')
      raise "needs called with improper path. Should be of the form: 'Category/Name'" if parts.length != 2

      libs = Library.where(name: parts[1], category: parts[0])
      raise "could not find library '#{path}'" if libs.empty?

      class_eval(libs[0].source.content, path)
    end
  end

  def self.make_namespace(code, source_name: '(eval)')
    namespace = Class.new.extend(Namespace)
    namespace.class_eval(code.content, source_name)

    namespace
  end

  def self.get_arguments(code)
    namespace = make_namespace(code)
    p = namespace::Protocol.new

    if p.respond_to? 'arguments'
      p.arguments
    else
      {}
    end
  end

end
