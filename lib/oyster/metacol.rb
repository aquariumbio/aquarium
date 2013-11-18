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

    def markings t
      t.parents.collect { |p| p.marking }
    end

    def all_markings
      @places.collect { |p| p.marking }
    end

    def done?
      all_markings.inject(:+) == 0
    end

    def check_transitions

      @transitions.each do |t| 
        t.firing = markings(t).inject(:*) > 0 && ( t.check_condition @scope )
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
            set_wires c
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

    def set_arguments p

      p.arg_expressions.each do |k,h|
         p.arguments[k] = @scope.evaluate p.arg_expressions[k]
      end

    end

    def set_wires p

      (@wires.reject { |w| @places[w.dest[:place]] != p }).each do |w|

        if @places[w.source[:place]].completed?
          r = @places[w.source[:place]].return_value
          if r
            p.arguments[w.dest[:name].to_sym] = r[w.source[:name].to_sym]
          end
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
