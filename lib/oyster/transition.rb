module Oyster

  class Transition < Lang::Scope

    attr_accessor :firing, :parents, :condition, :children

    def initialize

      @parents = []      # A list of places
      @children = []     # A list of places
      @condition = ""    # A string that evaluates to true of false to determine whether to fire the transitions
      @firing = false    # Whether the transition is firing.
      @program = []      # An array of assignments that should be run before starting children.

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
        scope.set(a[:lhs], scope.evaluate(a[:rhs]))
      end
    end

    def check_condition scope
      # ans = scope.evaluate @condition
      ans = eval(scope.substitute @condition)
      # puts "#{condition} --> #{ans}"
      ans
    end

    def to_s
      p = parents.collect { |p| p.protocol }
      c = children.collect { |p| p.protocol }
      "#{p} => #{c} when #{@condition}"
    end

    ###################################################################################
    # extra functions available in transition expressions
    #

    def completed j
      if j < @parents.length
        @parents[j].completed?
      else
        false
      end
    end

    def completed j
      if j < @parents.length
        @parents[j].completed?
      else
        false
      end
    end

    def error j
      if j < @parents.length
        @parents[j].error?
      else
        false
      end
    end

    def return_value j, name
      if j < @parents.length
        @parents[j].return_value[name.to_sym]
      else
        false
      end
    end

    def hours_elapsed j, h
      if j < @parents.length
        return Time.now.to_i - @parents[j].started >= h.hours.to_i
      else
        return false
      end
    end

    def minutes_elapsed j, m
      if j < @parents.length
        return Time.now.to_i - @parents[j].started >= m.minutes.to_i
      else
        return false
      end
    end

  end

end
