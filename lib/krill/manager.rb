module Krill

  class ThreadStatus
    attr_accessor :running
  end

  class Manager

    attr_accessor :thread

    def initialize jid, debug

      # Start new thread
      @mutex = Mutex.new
      @thread_status = ThreadStatus.new
      @thread_status.running = false
      @debug = debug

      # Get job info
      @jid = jid
      @job = Job.find(jid)
      @code = Repo::contents @job.path, @job.sha
      initial_state = JSON.parse @job.state, symbolize_names: true
      @args = initial_state[0][:arguments]

      # Create Namespace
      @namespace = Krill::make_namespace @code

      # Add base_class ancestor to user's code
      @base_class = make_base
      insert_base_class @namespace, @base_class

      # Make a base object
      @base_object = Class.new.extend(@base_class)

      # Make protocol
      @protocol = @namespace::Protocol.new

    end

    ##################################################################################
    # TRICKY THREAD STUFF
    #

    def start_thread

      @thread_status.running = true

      @thread = Thread.new {

        begin

          @job.reload.pc = 0          # what if this fails?
          @job.save                   # what if this fails?
          appended_complete = false

          begin

            rval = @protocol.main

          rescue Exception => e

            puts "#{@job.id}: EXCEPTION #{e.to_s} + #{e.backtrace[0,10]}"
            @base_object.error e

          else

            @job.reload.append_step operation: "complete", rval: rval 
            appended_complete = true

          ensure

            @job.reload.pc = Job.COMPLETED # what if this fails?

            unless appended_complete
              @job.append_step operation: "next", time: Time.now, inputs: {}
              @job.append_step operation: "aborted", rval: {}
            end

            @job.save # what if this fails?

            ActiveRecord::Base.connection.close

            @mutex.synchronize { @thread_status.running = false }

          end

        rescue Exception => main_error

          puts "#{@job.id}: SERIOUS EXCEPTION #{main_error.to_s}: #{main_error.backtrace[0,10]}"

          if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
             ActiveRecord::Base.connection.close
             puts "#{@job.id}: Closing ActiveRecord connection"
          end

        end

      }

    end

    def debugger

      begin

        @job.reload.pc = 0          # what if this fails?
        @job.save                   # what if this fails?
        appended_complete = false

        begin

          rval = @protocol.main

        rescue Exception => e

          puts "#{@job.id}: EXCEPTION #{e.to_s} + #{e.backtrace[0,10]}"
          @base_object.error e

        else

          @job.reload.append_step operation: "complete", rval: rval 
          appended_complete = true

        ensure

          @job.reload.pc = Job.COMPLETED # what if this fails?

          unless appended_complete
            @job.append_step operation: "next", time: Time.now, inputs: {}
            @job.append_step operation: "aborted", rval: {}
          end

          @job.save # what if this fails?

        end

      rescue Exception => main_error

        puts "#{@job.id}: SERIOUS EXCEPTION #{main_error.to_s}: #{main_error.backtrace[0,10]}"

        if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
           ActiveRecord::Base.connection.close
           puts "#{@job.id}: Closing ActiveRecord connection"
        end

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

    def wait secs

      n = 0
      running = true
      @mutex.synchronize { running = @thread_status.running }

      while running
        return "not_ready" unless n < 10*secs # wait two seconds
        n += 1
        sleep(0.1) 
        @mutex.synchronize { running = @thread_status.running }
      end

      @job.reload

      if @job.pc == -2
        return "done"
      else
        return "ready"
      end

    end

    def check_again

      if @thread.alive?
        wait 20
      else 
        "done"
      end

    end

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

        "done"

      end

    end

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
      b.send(:include,Base)
      b.module_eval "def jid; #{@jid}; end"
      b.module_eval "def input; #{@args}; end"

      if @debug
        b.module_eval "def debug; true; end"
      end

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

    def insert_base_class obj, mod

      obj.constants.each do |c|

        k = obj.const_get(c)

        if k.class == Module
          eigenclass = class << self
            self
          end
          eigenclass.send(:include,mod) unless eigenclass.include? mod
          insert_base_class k, mod
        elsif k.class == Class
          k.send(:include,mod) unless k.include? mod
          insert_base_class k, mod
        end

      end

    end

  end

end
