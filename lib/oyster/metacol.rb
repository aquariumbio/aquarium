module Oyster

  class Metacol

    attr_accessor :places, :transitions, :wires

    def initialize
      @places = []
      @transitions = []
      @wires = []
    end

    def place p
      @places.push p
      p
    end

    def transition t
      @transitions.push t
      t
    end

    def wire s, ret, d, arg
      @wires.push( Wire.new(  { place: s, name: ret }, { place: d, name: arg } ) )
      self
    end

    def start
      @places.each do |p|
        if p.marking > 0
          p.start
        end
      end
    end

    def check_transitions

      @transitions.each do |t| 
        markings = t.parents.collect { |p| p.marking }
        t.firing = markings.inject(:*) > 0 && t.check_condition
      end

    end # check_transitions

    def fire

      @transitions.each do |t|

        if t.firing

          t.parents.each { |p| p.unmark }
          t.children.each do |c|
            c.mark
            set_arguments c
            c.start
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

  end

  def update
    check_transitions  
    fire
  end

end
