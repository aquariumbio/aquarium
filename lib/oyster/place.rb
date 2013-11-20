module Oyster

  class Place

    attr_accessor :jobs, :marking, :arg_expressions, :arguments, :protocol, :sha

    def initialize

      @protocol = ''     # The path to the protocol in github
      @arguments = {}    # A hash or argument names and values to send to the protocol when starting.                     
      @arg_expressions = {}  # Unevaluated expressions. Any argument not supplied here, 
                             # must be set using a wire (see below).

      @jobs = []         # A list of job ids associated with this place. Every time a place becomes
                         # active, a new job id is pushed onto the stack.
      @marking = 0       # How many marks the place has (in the Petri Net sense)

      @desired_start = "now"        # When the job should be started
      @latest_start = "tomorrow"    # Latest time the job should be started

      @sha = nil

      self

    end
    
    def mark
      @marking += 1
      self
    end

    def unmark
      @marking -= 1
      self
    end

    def proto p
      @protocol = p
      self
    end

    def desired exp
      @desired_start = exp
    end

    def latest exp
      @latest_start = exp
    end

    def group g
      @group = g
      self
    end

    def evaluated_arguments scope
      args = {}
      @arg_expressions.each do |v,e|
        args[v] = scope.evaluate e
      end
      args
    end

    def start who, scope

      puts "Starting #{@protocol} with sha = #{@sha}"

      begin

        if @sha == nil
          @sha = Oyster.get_sha @protocol
        end

        @jobs.push( Oyster.submit( {
          sha: @sha, 
          path: @protocol, 
          args: evaluated_arguments(scope),
          desired: eval(@desired_start), 
          latest: eval(@latest_start), 
          group: @group ? @group : who,
          who: who } ) )

      rescue Exception => e
        raise "Could not submit protocol #{@protocol}. " + e.to_s + e.backtrace.to_s
        @marking -= 1
      end

    end

    def completed?
      if @jobs.length > 0
        j = Job.find(@jobs.last)
        return( j.pc == Job.COMPLETED )
      else
        return false
      end
    end

    def error?
      if @jobs.length > 0
        j = Job.find(@jobs.last)
        entries = j.logs.reject { |l| l.entry_type != 'CANCEL' && l.entry_type != 'ERROR' && l.entry_type != 'ABORT' }
        return entries.length > 0
      else
        return false
      end
    end

    def return_value
      if @jobs.length > 0
        j = Job.find(@jobs.last)
        entries = j.logs.reject { |l| l.entry_type != 'return' }
        if entries.length == 0
          return nil
        else
          JSON.parse(entries.first.data,:symbolize_names => true)
        end
      else
        return nil
      end
    end

    def to_s
      "#{@protocol} for #{@group}"
    end

    #################################################################################################
    # Time
    #

    def now
      Time.now
    end

    def today_at h, m
      Time.now.midnight + h.hours + m.minutes
    end

    def tomorrow
      Time.now + 1.day
    end

    def tomorrow_at h, m
      Time.now.midnight + 1.day + h.hours + m.minutes
    end

    def minutes n
      Time.now + n.minutes
    end

    def hours n
      Time.now + n.hours
    end

    def days n
      Time.now + n.days
    end

  end

end
