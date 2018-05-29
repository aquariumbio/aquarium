# frozen_string_literal: true

module Oyster

  class Place

    attr_accessor :jobs, :marking, :arg_expressions, :arguments, :protocol, :sha, :name, :started

    def initialize

      @name = ''         # The name of the place
      @protocol = ''     # The path to the protocol in github
      @arguments = {}    # A hash or argument names and values to send to the protocol when starting.
      @arg_expressions = {} # Unevaluated expressions. Any argument not supplied here,
      # must be set using a wire (see below).

      @jobs = [] # A list of job ids associated with this place. Every time a place becomes
      # active, a new job id is pushed onto the stack.
      @marking = 0 # How many marks the place has (in the Petri Net sense)

      @started = Time.now.to_i # Time when the place was started

      @desired_start = 'now()'      # When the job should be started
      @window =        'days(1)'    # Latest time the job should be started

      @sha = nil

      self

    end

    def mark
      @marking += 1
      self
    end

    def marked?
      @marking > 0
    end

    def unmark
      @marking -= 1
      self
    end

    def proto(p)
      @protocol = p
      self
    end

    def desired(exp)
      @desired_start = exp
    end

    def window(exp)
      @window = exp
    end

    def group(g)
      @group = g
      self
    end

    def evaluated_arguments(scope)
      args = {}
      @arg_expressions.each do |v, e|
        args[v] = scope.evaluate e
      end
      args
    end

    def start(who, scope, id)

      @started = Time.now.to_i

      if @protocol != ''

        begin
          @sha = Oyster.get_sha @protocol if @sha.nil?

          puts "#{id}: Starting #{@protocol}, with sha = #{@sha}"

          desired = eval(@desired_start)

          if desired.to_i < Time.now.to_i - 1.day # meaning that the user entered something like
            # minutes(10), hours(4), or days(9) and we need to
            # add Time.now to get the right time

            desired = Time.now + eval(@desired_start)
          end

          puts "in place.start, who = #{who}"

          @jobs.push(Oyster.submit(
                       sha: @sha,
                       path: @protocol,
                       args: evaluated_arguments(scope),
                       desired: desired,
                       latest: desired + eval(@window),
                       group: @group ? scope.evaluate(@group) : who,
                       metacol_id: id,
                       who: who
                     ))
        rescue Exception => e
          raise "Could not submit protocol #{@protocol}. " + e.to_s + e.backtrace.to_s
          @marking -= 1
        end

      end

    end

    def completed?

      if @protocol != '' && !@jobs.empty?
        j = Job.find(@jobs.last)
        (j.pc == Job.COMPLETED)
      else
        @protocol == ''
      end

    end

    def error?
      if !@jobs.empty?
        j = Job.find(@jobs.last)
        j.error?
      else
        false
      end
    end

    def return_value
      Job.find(@jobs.last).return_value unless @jobs.empty?
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

    def today_at(h, m)
      Time.now.midnight + h.hours + m.minutes
    end

    def tomorrow
      Time.now + 1.day
    end

    def tomorrow_at(h, m)
      Time.now.midnight + 1.day + h.hours + m.minutes
    end

    def minutes(n)
      n.minutes
    end

    def hours(n)
      n.hours
    end

    def days(n)
      n.days
    end

  end

end
