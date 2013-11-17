module A

  def A.f x
    x + 1
  end

  class B
    def initialize x
      puts A.f x
    end
  end

end

A::B.new 1
