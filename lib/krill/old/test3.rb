module K

  module Namespace

      def needs content
          class_eval(content)
      end

  end

  class M

    def initialize

      namespace = Class.new.extend(Namespace)

      namespace.class_eval "

        needs 'class Thing; def initialize z; puts z; end; end'
        needs 'module Thang; def self.f x; -x; end; end'

        class C

          # include Thang

          def initialize
            t = Thing.new(Thang::f 1)
          end

        end"

      namespace::C.new

    end

  end

end

k = K::M.new
