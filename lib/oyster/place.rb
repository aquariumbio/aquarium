module Oyster

  class Place

    attr_reader :jobs
    attr_accessor :marking, :arg_expressions, :arguments, :protocol

    def initialize

      @protocol = ''     # The path to the protocol in github
      @arguments = {}    # A hash or argument names and values to send to the protocol when starting.                     

      @arg_expressions = {}  # Unevaluated expressions. Any argument not supplied here, 
                             # must be set using a wire (see below).

      @jobs = []         # A list of job ids associated with this place. Every time a place becomes
                         # active, a new job id is pushed onto the stack.
      @marking = 0       # How many marks the place has (in the Petri Net sense)
      @log = {}          # The log of the most recent job

      @desired_start = "now"        # When the job should be started
      @latest_start = "tomorrow"    # Latest time the job should be started

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
      @sha = Oyster.get_sha p
      self
    end

    def now
      Time.now
    end

    def tomorrow
      Time.now + 1.day
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

    def start who

      puts "Starting #{@protocol} with sha = #{@sha}"

      begin

        @jobs.push( Oyster.submit( {
          sha: @sha, 
          path: @protocol, 
          args: @arguments,
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

  end

end
