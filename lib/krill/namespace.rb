module Krill

  module Namespace
  
    def needs path

      p = "#{path}.rb"
      s = Repo::version p
      content = Repo::contents p, s
      eval(content)

    end

  end

  def self.make_namespace code
    namespace = Class.new.extend(Namespace)
    namespace.class_eval code
    namespace
  end

  def self.get_arguments code

    p = (make_namespace code)::Protocol.new

    if p.respond_to? "arguments"
      p.arguments
    else
      {}
    end

  end

end
