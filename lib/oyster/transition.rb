module Oyster

  class Transition

    attr_accessor :firing, :parents, :condition, :children

    def initialize 
      @parents = []      # A list of places
      @children = []     # A list of places
      @condition = ""    # A string that evaluates to true of false to determine whether to fire the transitions
      @firing = false    # Whether the transition is firing.
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

    def completed j
      if j < @parents.length
        @parents[j].completed?
      else
        false
      end
    end

    def check_condition
      eval @condition
    end

    def to_s 
      p = parents.collect { |p| p.protocol }
      c = children.collect { |p| p.protocol }
      "#{p} => #{c} when #{@condition}"
    end

  end

end
