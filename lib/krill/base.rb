module Krill

  module Base

    def show *page

      # Append page to job state
      append_step( { operation: "display", content: page } )

      # increment pc
      job = Job.find(jid)
      job.pc += 1
      job.save

      # stop and wait for technician to click OK
      mutex().synchronize { thread_status().running = false }
      Thread.stop

      # get technician input and return it
      JSON.parse(job.reload.state, symbolize_names: true).last[:inputs]

    end

    def error e

      append_step( { operation: "error", message: e.to_s, backtrace: e.backtrace[0,10] } )

    end

    private

    def append_step s

      job = Job.find(jid)
      state = JSON.parse job.state, symbolize_names: true
      state.push s
      job.state = state.to_json
      job.save

    end

  end

end
