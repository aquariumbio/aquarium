module Oyster

  class Transition

    attr_accessor :firing, :parents, :condition, :children

    def initialize 
      @parents = []      # A list of places
      @children = []     # A list of places
      @condition = ""    # A string that evaluates to true of false to determine whether to fire the transitions
      @firing = false    # Whether the transition is firing.
      @program = []         # An array of assignments that should be run before starting children.
    end

    def parent p
      @parents.push p
      self
    end

    def child c
      @children.push c
      self
    end

    def cond c
      @condition = c
      self
    end

    def prog p
      @program = p
      self
    end

    def run_program scope
      @program.each do |a|
        scope.set( a[:lhs], eval( scope.substitute a[:rhs] ) )
      end
    end

    def completed j
      if j < @parents.length
        @parents[j].completed?
      else
        false
      end
    end

    def check_condition scope
      ans = eval( scope.substitute @condition )
      puts "#{condition} --> #{ans}"
      ans
    end

    def to_s 
      p = parents.collect { |p| p.protocol }
      c = children.collect { |p| p.protocol }
      "#{p} => #{c} when #{@condition}"
    end

  end

end
