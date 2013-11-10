module Oyster

  class Transition

    attr_accessor :firing, :parent, :condition, :children

    def initialize parent
      @parent = parent   # A place
      @children = []     # A set of places
      @condition = ""    # A string that evaluates to true of false to determine whether to fire the transitions
      @firing = false     # Whether the transition is firing.
    end

    def child c
      @children.push c
      self
    end

    def cond c
      @condition = c
      self
    end

    def check_condition
      eval @condition
    end

  end

end
