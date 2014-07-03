module M

  def show msg
    puts msg
  end

end

class A

  module X
    def self.f
      show "in f"
    end
    class D
      def initialize
        show "Making a D"
      end
    end
  end

  class B 

    class E
    end

    class C < E
    end

    def main
      d = X::D.new
      show "in main"
      X::f      
    end

  end

end

class Object
  def eigenclass
    class << self
      self
    end
  end
end

def insert_parent obj, mod

  obj.constants.each do |c|

    k = obj.const_get(c)

    if k.class == Module
      k.eigenclass.send(:include,mod) unless k.eigenclass.include? mod
      insert_parent k, mod
    elsif k.class == Class
      k.send(:include,mod) unless k.include? mod
      insert_parent k, mod
    end
    
  end

end

def show_ancestry obj

  obj.constants.each do |c|

    k = obj.const_get(c)

    if k.class == Module
      puts c.to_s + " extended by " + (class << k; self end).included_modules.to_s
      show_ancestry k
    elsif k.class == Class
      puts c.to_s + " ancestors are " + k.ancestors.to_s
      show_ancestry k
    end
    
  end

end

m = Module.new
m.send(:include,M)

insert_parent A, m
show_ancestry A

puts "---------"
A::B.new.main







