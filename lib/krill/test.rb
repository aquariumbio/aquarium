module KrillBase

  def id
    nil
  end

  def show msg
    puts "#{id}: #{msg}"
  end

end

class Manager

  def initialize code, id

    @krill = Class.new
    @krill.extend(KrillBase)
    @krill.class_eval "def id; #{id}; end"
    @krill.class_eval code
    @c = @krill::C.new

  end

  def run
    @c.main
  end

end

a = Manager.new '

  puts id
  show "wow"

  module X
    def f x
      x+1
    end
  end

  class C
    include X
    def main
      puts self.class.ancestors.to_s
      show "In first main"
      return "First: #{f 0}: "
    end

  end', 1

b = Manager.new '

  class C

    def main
      puts self.class.superclass
      show "In second main"
      return "Second."
    end

  end', 2

puts a.run
puts b.run
puts a.run
