module Krill

  class ThreadStatus
    attr_accessor :running
  end

  class Manager

    attr_accessor :job, :thread

    def initialize jid

      @jid = jid
      @job = Job.find(jid)
      @path = @job.path
      @sha = @job.sha
      @code = Repo::contents @path, @sha

      @mutex = Mutex.new
      @thread_status = ThreadStatus.new
      
      @thread_status.running = false

      initial_state = JSON.parse @job.state, symbolize_names: true
      @args = initial_state[0][:arguments]

      # Create Namespace
      @namespace = Class.new
      @namespace.extend(Namespace)
      @namespace.class_eval @code

      # Create Base
      @base = Module.new
      @base.send(:include,Base)
      @base.module_eval "def jid; #{@jid}; end"
      @base.module_eval "def input; #{@args}; end"

      manager_mutex = @mutex
      @base.send :define_method, :mutex do
        manager_mutex
      end

      manager_thread_status = @thread_status
      @base.send :define_method, :thread_status do
        manager_thread_status
      end

      # Add base ancestor
      insert_base_class @namespace, @base

      # Make protocol
      @protocol = @namespace::Protocol.new

      @thread = Thread.new { 

        @mutex.synchronize { @thread_status.running = true }

        @job.reload
        @job.pc = 0
        @job.save

        puts "#{jid}: STARTING THREAD #{Thread.current}"
        begin 
          @protocol.main
        rescue Exception => e
          puts "#{jid}: EXCEPTION #{e.to_s} + #{e.backtrace[0,10]}"
          begin 
            error e
          rescue Exception => d
            puts "#{jid}: A SERIOUS PROBLEM: #{d.to_s}"
          end
        end

        puts "#{jid}: COMPLETING"

        @job.reload
        @job.pc = Job.COMPLETED
        @job.save

        puts "#{jid}: DONE"

        append_step( { operation: "complete" } )
        ActiveRecord::Base.connection.close
        @mutex.synchronize { @thread_status.running = false }

      }

    end

    def wake

      @mutex.synchronize { @thread_status.running = true }
      @thread.wakeup
      temp = true
      @mutex.synchronize { temp = @thread_status.running }
      while temp
        sleep(0.1) # keeps the processing from being a hog?
        @mutex.synchronize { temp = @thread_status.running }
      end

    end

    def continue

      puts "#{@jid}: CONTINUE"

      if @thread.alive?
        puts "#{@jid}: ALIVE. ATTEMPTING TO WAKE"
        wake
        puts "#{@jid}: WAKE SUCCEEDED"
      end

      @thread.alive?

    end

    def error e
      append_step( { operation: "error", message: e.to_s, backtrace: e.backtrace[0,10] } )
      @job.reload
      @job.pc = Job.COMPLETED
      @job.save
    end

    def append_step s

      @job.reload
      state = JSON.parse @job.state, symbolize_names: true
      state.push s
      @job.state = state.to_json
      @job.save

    end

    def insert_base_class obj, mod

      obj.constants.each do |c|

        k = obj.const_get(c)

        if k.class == Module
          puts c
          k.eigenclass.send(:include,mod) unless k.eigenclass.include? mod
          insert_base_class k, mod
        elsif k.class == Class
          puts c
          k.send(:include,mod) unless k.include? mod
          insert_base_class k, mod
        end

      end

    end

    def show_ancestry obj

      obj.constants.each do |c|

        k = obj.const_get(c)

        if k.class == Module
          puts c.to_s + " extended by " + (class << k; self end).included_modules.to_s
          show_ancestry k
        elsif k.class == Class
          puts c.to_s + " ancestors are " + k.ancestors.to_s
          show_ancestry k
        end

      end

    end

  end
 
end
