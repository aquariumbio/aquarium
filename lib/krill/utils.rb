# frozen_string_literal: true

module Krill

  class ProtocolHandler

    def needs(path)

      p = "#{path}.rb"
      s = Repo.version p

      content = Repo.contents p, s

      eval(content)

    end

    def with(mod)

      class_eval do
        include mod
      end

    end

  end

end
