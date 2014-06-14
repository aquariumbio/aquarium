class A

  def initialize

    @x = "A only"

    eval("class B
      def f x
        puts "x = #{@x}."
        x+1
      end
    end")

  end

  def g

    b = B.new
    puts b.f 0

  end

end

a = A.new
a.g

b = B.new
