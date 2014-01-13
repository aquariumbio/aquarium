module Oyster

  class Argument # used for compatability with protocol arguments
    attr_reader :name, :type, :description
    def initialize n, t, d
      @name = n
      @type = t
      @description = d
    end
  end

  class Metacol

    attr_accessor :places, :transitions, :wires, :scope, :arguments, :id

    def initialize
      @arguments = []
      @places = []
      @transitions = []
      @wires = []
      @who = ''
      @scope = Lang::Scope.new
      @id = -1
    end

    def args
      @arguments.collect { |a| Argument.new a[:name], a[:type], a[:description] }
    end

    def place p
      @places.push p
      p
    end

    def transition t
      #puts "Added transition with condition #{t.condition}"
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

    def start args

      # Set argument values in scope
      args.each do |k,v|
        @scope.set k, v
      end

      # Start all marked places
      @places.each do |p|
        if p.marking > 0
          p.start @who, @scope, @id
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
            set_wires c
            c.start @who, @scope, @id
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

    def set_wires p

      (@wires.reject { |w| puts @places[w.dest[:place]] != p }).each do |w|

        if @places[w.source[:place]].completed?
          r = @places[w.source[:place]].return_value
          if r
            value = r[w.source[:name].to_sym]
            if value.class == String
              p.arg_expressions[w.dest[:name].to_sym] = '"' + value + '"'
            else
              p.arg_expressions[w.dest[:name].to_sym] = "#{value}"
            end
          end
        else
          j = @places[w.source[:place]].jobs.last
          pc = Job.find(j).pc
          raise "Source place for wire #{w.pretty @places} has uncompleted job #{j} with pc=#{pc}}."
        end

      end

      puts "Arguments set to #{p.arg_expressions}"

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

    def state

      { 
        places: @places.collect { |p| { marking: p.marking, started: p.started, jobs: p.jobs, sha: p.sha } },
        stack: @scope.stack
      }

    end

    def for_layout
      { 
        places: @places.collect { |p| { name: p.name, marking: p.marking } },
        transitions: @transitions.collect { |t| { preset: t.parents.collect { |p| p.name }, postset: t.children.collect { |c| c.name } } }
      }
    end

    def set_state s

      for i in 0..(@places.length-1)

        @places[i].marking = s[:places][i][:marking]
        @places[i].started = s[:places][i][:started]
        @places[i].jobs = s[:places][i][:jobs]
        @places[i].sha = s[:places][i][:sha]

      end

      @scope = Scope.new
      @scope.set_stack s[:stack]

    end

  end

end
