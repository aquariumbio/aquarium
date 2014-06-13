module Krill

  class ProtocolHandler

    attr_accessor :job

    def initialize jid

      @job = Job.find(jid)

      @thread = Thread.new { 

        Thread.stop
         
        protocol

        @job.reload
        @job.pc = Job.COMPLETED
        @job.save

        ActiveRecord::Base.connection.close

      }

    end

    def protocol

      x = 1
      display( { title: "A step", note: "x = #{x}" } )
      x = 2
      display( { title: "A step", note: "x = #{x}" } )

    end

    def append_step s

      @job.reload
      state = JSON.parse @job.state, symbolize_names: true
      state.push s
      @job.state = state.to_json
      @job.save

    end

    def display page

      append_step page

      @job.reload
      @job.pc += 1
      @job.save

      Thread.stop

    end

    def start

      @job.reload
      @job.pc = 0
      @job.save

      @thread.wakeup
      

    end

    def continue

      if @thread.alive?
        @thread.wakeup

      end

      @thread.alive?

    end

  end
 
end
