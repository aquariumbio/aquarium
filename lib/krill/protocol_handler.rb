module Krill

  class ProtocolHandler

    attr_accessor :job, :thread

    def initialize jid

      @job = Job.find(jid)
      @path = @job.path
      @sha = @job.sha
      @content = Repo::contents @path, @sha
      @mutex = Mutex.new
      @running = false

      initial_state = JSON.parse @job.state, symbolize_names: true
      @args = initial_state[0][:arguments]

      def input
        @args
      end

      eval(@content) # adds protocol def to this class
      
      @thread = Thread.new { 

        Thread.stop
        
        begin 
          protocol
        rescue Exception => e
          error e.to_s
        end

        @job.reload
        @job.pc = Job.COMPLETED
        @job.save

        append_step( { operation: "complete" } )

        ActiveRecord::Base.connection.close

        @mutex.synchronize { @running = false }

      }

    end

    def error message
      append_step( { operation: "error", message: message } )
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

    def display page

      append_step( { operation: "display", content: page } )

      @job.reload
      @job.pc += 1
      @job.save

      @mutex.synchronize { @running = false }
      Thread.stop

      @job.reload
      JSON.parse(@job.state, symbolize_names: true).last[:inputs]

    end

    def wake

      @mutex.synchronize { @running = true }
      @thread.wakeup
      temp = true
      @mutex.synchronize { temp = @running }
      while temp
        sleep(0.1)
        @mutex.synchronize { temp = @running }
      end

    end

    def start

      @job.reload
      @job.pc = 0
      @job.save
      wake

    end

    def continue

      if @thread.alive?
        wake
      end

      @thread.alive?

    end

  end
 
end
