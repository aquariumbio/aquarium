module Oyster

  class Metacol

    attr_accessor :places, :transitions, :wires, :scope

    def initialize
      @places = []
      @transitions = []
      @wires = []
      @who = ''
      @scope = Lang::Scope.new
    end

    def place p
      @places.push p
      p
    end

    def transition t
      puts "Added transition with condition #{t.condition}"
      @transitions.push t
      t
    end

    def wire s, ret, d, arg
      @wires.push( Wire.new(  { place: s, name: ret }, { place: d, name: arg } ) )
      self
    end

    def who u
      @who = u
      self
    end

    def start
      @places.each do |p|
        if p.marking > 0
          p.start @who
        end
      end
    end

    def check_transitions

      @transitions.each do |t| 
        markings = t.parents.collect { |p| p.marking }
        t.firing = markings.inject(:*) > 0 && ( t.check_condition @scope )
      end

    end # check_transitions

    def fire

      @transitions.each do |t|

        if t.firing

          t.parents.each { |p| p.unmark }
          t.run_program @scope
          t.children.each do |c|
            c.mark
            set_arguments c
            c.start @who
          end

        end

      end

    end # fire

    def firing
      @transitions.collect { |t| t.firing }
    end

    def marking
      @places.collect { |p| p.marking }
    end

    def find_wire_to p, s
      @wires.each do |w|
        if w.dest[:place] == p && w.dest[:name].to_sym == s
          return w
        end
      end
      return nil
    end

    def set_arguments p

      p.arguments.each do |k,h|
        w = find_wire_to p, k
        if w # if wire, then get the value
          p.arguments[k][:v] = w.source[:place].return_value[w.source[:name].to_sym]
        else # otherwise evaluate with current scope
          p.arguments[k][:v] = @scope.evaluate p.arguments[k][:e]
        end
      end

      puts "Arguments set to #{p.arguments}"

    end

    def set_arguments_old p

      (@wires.reject { |w| w.dest[:place] != p }).each do |w|

        if w.source[:place].completed?
          p.arguments[w.dest[:name].to_sym] = w.source[:place].return_value[w.source[:name].to_sym]
          puts "Arguments set to #{p.arguments}"
        else
          raise "Source place for wire has no jobs"
        end

      end

      puts "Arguments set to #{p.arguments}"

    end

    def update
      check_transitions  
      fire
    end

    def to_s
      s = ""
      @places.each do |p|
        s += p.to_s + "\n"
      end

      @transitions.each do |t|
        s += t.to_s + "\n"
      end

      @wires.each do |w|
        s += w.to_s + "\n"
      end
      s
    end
       

  end

end
