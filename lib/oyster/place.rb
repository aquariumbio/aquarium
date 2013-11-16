module Oyster

  class Place

    attr_reader :jobs
    attr_writer :protocol
    attr_accessor :marking, :arguments

    def initialize
      @protocol = ''     # The path to the protocol in github
      @arguments = {}    # A hash or argument names and values to send to the protocol when starting.
                         # Any argument not supplied here, must be set using a wire (see below).
      @jobs = []         # A list of job ids associated with this place. Every time a place becomes
                         # active, a new job id is pushed onto the stack.
      @marking = 0       # How many marks the place has (in the Petri Net sense)
      @log = {}          # The log of the most recent job
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
      @sha = get_sha p
      self
    end

    def start
      puts "Starting #{@protocol} with sha = #{@sha}"
      begin
        @jobs.push( submit @sha, @protocol, @arguments, { desired: Time.now, latest: Time.now + 1.day, group: 'klavins' } )
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

  end

end
