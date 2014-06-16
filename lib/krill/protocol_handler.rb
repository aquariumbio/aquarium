module Krill

  class ProtocolHandler

    attr_accessor :__krill__job, :__krill__thread

    def initialize __krill__jid

      @__krill__jid = __krill__jid
      @__krill__job = Job.find(__krill__jid)
      @__krill__path = @__krill__job.path
      @__krill__sha = @__krill__job.sha
      @__krill__content = Repo::contents @__krill__path, @__krill__sha
      @__krill__mutex = Mutex.new
      @__krill__running = false

      initial_state = JSON.parse @__krill__job.state, symbolize_names: true
      @__krill__args = initial_state[0][:arguments]

      def input
        @__krill__args
      end

      def job
        @__krill_jid
      end

      eval(@__krill__content) # adds protocol def to this class
      
      @__krill__thread = Thread.new { 

        Thread.stop
        
        begin 
          protocol
        rescue Exception => e
          __krill__error__ e.to_s
        end

        @__krill__job.reload
        @__krill__job.pc = Job.COMPLETED
        @__krill__job.save

        __krill__append_step__( { operation: "complete" } )

        ActiveRecord::Base.connection.close

        @__krill__mutex.synchronize { @__krill__running = false }

      }

    end

    def display page

      __krill__append_step__( { operation: "display", content: page } )

      @__krill__job.reload
      @__krill__job.pc += 1
      @__krill__job.save

      @__krill__mutex.synchronize { @__krill__running = false }
      Thread.stop

      @__krill__job.reload
      JSON.parse(@__krill__job.state, symbolize_names: true).last[:inputs]

    end

    def __krill__error__ message
      __krill__append_step__( { operation: "error", message: message } )
      @__krill__job.reload
      @__krill__job.pc = Job.COMPLETED
      @__krill__job.save
    end

    def __krill__append_step__ s

      @__krill__job.reload
      state = JSON.parse @__krill__job.state, symbolize_names: true
      state.push s
      @__krill__job.state = state.to_json
      @__krill__job.save

    end

    def __krill__wake__

      @__krill__mutex.synchronize { @__krill__running = true }
      @__krill__thread.wakeup
      temp = true
      @__krill__mutex.synchronize { temp = @__krill__running }
      while temp
        sleep(0.1)
        @__krill__mutex.synchronize { temp = @__krill__running }
      end

    end

    def __krill__start__

      @__krill__job.reload
      @__krill__job.pc = 0
      @__krill__job.save
      __krill__wake__

    end

    def __krill__continue__

      if @__krill__thread.alive?
        __krill__wake__
      end

      @__krill__thread.alive?

    end

  end
 
end
