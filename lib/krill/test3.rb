module M

    def self.needs content
        eval(content)
    end

    needs "class Thing; def initialize; puts 'ok'; end; end"

end

code="class C

      def initialize
        t = Thing.new
      end

    end"



M::C.new
