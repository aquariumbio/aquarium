# frozen_string_literal: true

module Krill

  class ThreadStatus
    attr_accessor :running
  end

  class Manager
    # accessible for testing
    attr_reader :thread, :sandbox

    def initialize(job, debug)
      # TODO: make this take a Job object as the parameter instead of the ID

      @debug = debug

      # Start new thread
      @mutex = Mutex.new
      @thread_status = ThreadStatus.new
      @thread_status.running = false

      raise "Error: job #{job.id} has no operations" if job.operations.empty?

      @sandbox = ExecutionSandbox.new(job: job, debug: debug, mutex: @mutex, thread_status: @thread_status)
    end

    ##################################################################################
    # TRICKY THREAD STUFF
    #

    def start_thread
      @thread_status.running = true
      @thread = Thread.new do
        @sandbox.execute
      rescue KrillError, ProtocolError => e
        notify(@sandbox.job)
        raise e
      rescue Exception => e
        # TODO: determine what other exceptions might happen here and be more specific
        puts "#{@sandbox.job.id}: SERIOUS EXCEPTION #{e}: #{e.backtrace[0, 10]}"
        raise e
      ensure
        @mutex.synchronize { @thread_status.running = false }

        if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
          ActiveRecord::Base.connection.close
          puts "#{@sandbox.job.id}: Closing ActiveRecord connection"
        end
      end
    end

    def debugger
      @sandbox.execute
    rescue KrillError, ProtocolError => e
      raise e
    rescue Exception => e
      # TODO: determine what other exceptions might happen here and be more specific
      puts "#{@sandbox.job.id}: SERIOUS EXCEPTION #{e}: #{e.backtrace[0, 10]}"

      if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.close
        puts "#{@sandbox.job.id}: Closing ActiveRecord connection"
      end

      raise e
    end

    def run
      if @sandbox.debug
        debugger
      else
        start_thread
        wait 20 # This so that you wait until either the step is done or 20 seconds is up.
        # It doesn't have to wait the whole 20 seconds if the step finishes quickly.
      end
    end

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

    # command called by client
    def start
      run
    end

    # client command
    def check_again
      if @thread.alive?
        wait 20
      else
        'done'
      end
    end

    # client command
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

    # called by client abort command
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
