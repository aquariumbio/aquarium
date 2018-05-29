module Krill

  module Namespace

    def needs(path)

      parts = path.split('/')
      raise "needs called with improper path. Should be of the form: 'Category/Name'" if parts.length != 2

      libs = Library.where(name: parts[1], category: parts[0])
      raise "could not find library '#{path}'" if libs.empty?

      class_eval(libs[0].code('source').content)

    end

  end

  def self.make_namespace(code)

    namespace = Class.new.extend(Namespace)
    namespace.class_eval code
    namespace

  end

  def self.get_arguments(code)

    p = (make_namespace code)::Protocol.new

    if p.respond_to? 'arguments'
      p.arguments
    else
      {}
    end

  end

end
