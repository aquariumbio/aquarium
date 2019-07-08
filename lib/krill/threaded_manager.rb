# frozen_string_literal: true

module Krill

  class ThreadStatus
    attr_accessor :running
  end

  # Manages threaded execution of a job in technician interface.
  # Provides methods called by {Krill::Client} via {Krill::Server}.
  #
  # See {DebugManager} for manager used in test and debug modes.
  class ThreadedManager
    # accessible for testing
    attr_reader :thread, :sandbox

    # Initializes a {ThreadedManager} object with the given job.
    #
    # @param job [Job] the job
    # @raise [StandardError] if the job has no operations
    # @raise [KrillSyntaxError] if the job's protocol has a syntax error
    def initialize(job)
      raise "Error: job #{job.id} has no operations" if job.operations.empty?

      @mutex = Mutex.new
      @thread_status = ThreadStatus.new
      @thread_status.running = false

      @sandbox = ProtocolSandbox.new(job: job, mutex: @mutex, thread_status: @thread_status)
    end

    ##################################################################################
    # TRICKY THREAD STUFF
    #

    # Starts the thread for running this job.
    def start_thread
      @thread_status.running = true
      @thread = Thread.new do
        @sandbox.execute
      rescue KrillError, KrillSyntaxError, ProtocolError => e
        notify(@sandbox.job)
        raise e
      ensure
        @mutex.synchronize { @thread_status.running = false }

        if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
          ActiveRecord::Base.connection.close
          puts "#{@sandbox.job.id}: Closing ActiveRecord connection"
        end
      end
    end

    # Starts the thread and waits for 20 seconds if needed.
    #
    # Method called by client via server.
    def start
      start_thread
      wait(20) # This so that you wait until either the step is done or 20 seconds is up.
      # It doesn't have to wait the whole 20 seconds if the step finishes quickly.
    end

    # Waits for the number of seconds while the thread is still running.
    #
    # @param secs [Integer] the number of seconds to wait
    # @return [String] 'done' if execution is complete,
    def wait(secs)
      n = 0
      running = true
      @mutex.synchronize { running = @thread_status.running }

      while running
        return 'not_ready' unless n < 10 * secs # wait two seconds

        n += 1
        sleep(0.1)
        @mutex.synchronize { running = @thread_status.running }
      end

      @sandbox.reload
      return 'done' if @sandbox.done?

      'ready'
    end

    # Checks status of the job.
    #
    # Method called by client via server.
    def check_again
      if @thread.alive?
        wait 20
      else
        'done'
      end
    end

    # Continues the job.
    #
    # Method called by client via server.
    def continue
      if @thread.alive?
        @mutex.synchronize do
          unless @thread_status.running
            @thread_status.running = true
            @thread.wakeup
          end
        end
        wait 20
      else
        'done'
      end
    end

    # Stops (aborts) this job.
    #
    # Method called by client via server.
    def stop
      # TODO: can this be elsewhere?
      puts "Stopping job #{@sandbox.job.id}"

      @thread.kill
      @mutex.synchronize { @thread_status.running = false }
    end

    #
    # END TRICKY THREAD STUFF
    ###########################################################################

    # Associate a crash message to each operation of the given job.
    #
    # @param job [Job] the job
    def notify(job)
      job.operations.each do |operation|
        puts("notifying #{operation.id}")
        operation.associate(
          :job_crash,
          "Operation canceled when job #{job.id} crashed"
        )
      end
    end
  end
end
