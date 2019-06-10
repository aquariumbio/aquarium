# frozen_string_literal: true

module Krill

  class ThreadStatus
    attr_accessor :running
  end

  class Manager
    attr_reader :thread

    def initialize(jid, debug)
      # TODO: make this take a Job object as the parameter instead of the ID

      @jid = jid
      @debug = debug

      # Start new thread
      @mutex = Mutex.new
      @thread_status = ThreadStatus.new
      @thread_status.running = false

      begin
        @job = Job.find(jid)
      rescue ActiveRecord::RecordNotFound
        raise "Error: Job #{jid} not found"
      end
      raise "Error: job #{@job.id} has no operations" if @job.operations.empty?

      begin
        initial_state = JSON.parse(@job.state, symbolize_names: true)
      rescue JSON::ParseError
        raise "Error: parse error reading state of job #{@job.id}"
      end
      @args = initial_state[0][:arguments]

      @code = @job.operations.first.operation_type.protocol
      @namespace = Krill.make_namespace(@code) # Create Namespace

      # Add base_class ancestor to user's code
      @base_class = make_base
      insert_base_class(@namespace, @base_class)

      @base_object = Class.new.extend(@base_class)
      @protocol = @namespace::Protocol.new
      raise 'Error: failed to add debug method to protocol' unless @protocol.respond_to?(:debug)
      raise 'Error: failed to add input method to protocol' unless @protocol.respond_to?(:input)
      raise 'Error: failed to add jid method to protocol' unless @protocol.respond_to?(:jid)
    end

    ##################################################################################
    # TRICKY THREAD STUFF
    #

    # TODO: standardize handling of Exceptions in execution
    # Possibilities:
    # NoMemoryError
    # ScriptError - load errors including SyntaxError and NotImplementedError
    # SecurityError
    # StandardError
    # SystemExit - explicit call to Kernel.exit
    # SystemStackError

    def start_thread
      @thread_status.running = true
      @thread = Thread.new do

        @job.start # what if this fails?
        appended_complete = false

        begin
          return_value = @protocol.main
        rescue Exception => e
          puts "#{@job.id}: EXCEPTION #{e}"
          puts e.backtrace[0, 10]
          @base_object.error(e)
        else
          @job.reload.append_step(operation: 'complete', rval: return_value)
          appended_complete = true
        ensure
          if appended_complete
            @job.stop
          else
            @job.stop 'error'
            notify(@job)
            @job.reload
            @job.append_step(operation: 'next', time: Time.zone.now, inputs: {})
            @job.append_step(operation: 'aborted', rval: {})
          end
          @job.save # what if this fails?
          ActiveRecord::Base.connection.close
          @mutex.synchronize { @thread_status.running = false }
        end
      rescue Exception => e
        puts "#{@job.id}: SERIOUS EXCEPTION #{e}: #{e.backtrace[0, 10]}"

        if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
          ActiveRecord::Base.connection.close
          puts "#{@job.id}: Closing ActiveRecord connection"
        end
      end
    end

    def debugger
      @job.start # what if this fails?
      appended_complete = false

      begin
        return_value = @protocol.main
      rescue Exception => e
        puts "#{@job.id}: EXCEPTION #{e}"
        puts e.backtrace[0, 10]
        @base_object.error e
      else
        @job.reload.append_step(operation: 'complete', rval: return_value)
        appended_complete = true
      ensure
        if appended_complete
          @job.stop # what if this fails?
        else
          @job.reload
          @job.stop 'error'
          @job.append_step operation: 'next', time: Time.zone.now, inputs: {}
          @job.append_step operation: 'aborted', rval: {}
        end

        @job.save # what if this fails?
      end
    rescue Exception => e
      puts "#{@job.id}: SERIOUS EXCEPTION #{e}: #{e.backtrace[0, 10]}"

      if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.close
        puts "#{@job.id}: Closing ActiveRecord connection"
      end
    end

    def run
      if @protocol.debug
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

      @job.reload

      return 'done' if @job.pc == -2

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
      puts "Stopping job #{@job.id}"

      @thread.kill
      @mutex.synchronize { @thread_status.running = false }
    end

    #
    # END TRICKY THREAD STUFF
    ###########################################################################

    def make_base
      b = Module.new
      b.send(:include, Base)
      b.module_eval("def jid; #{@jid}; end", 'generated_base')
      b.module_eval("def input; #{@args}; end", 'generated_base')
      b.module_eval('def debug; true; end', 'generated_base') if @debug

      manager_mutex = @mutex
      b.send :define_method, :mutex do
        manager_mutex
      end

      manager_thread_status = @thread_status
      b.send :define_method, :thread_status do
        manager_thread_status
      end

      b
    end

    def insert_base_class(obj, mod)
      obj.constants.each do |c|
        k = obj.const_get(c)
        if k.class == Module
          eigenclass = class << self
                         self
          end
          eigenclass.send(:include, mod) unless eigenclass.include? mod
          insert_base_class k, mod
        elsif k.class == Class
          k.send(:include, mod) unless k.include? mod
          insert_base_class k, mod
        end
      end
    end
  end

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
