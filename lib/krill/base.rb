module Krill

  module Base

    def debug
      false
    end

    def show

      page = ShowBlock.new.run(&Proc.new)

      # increment pc
      job = Job.find(jid)
      job.append_step operation: "display", content: page
      job.pc += 1
      job.save

      if !debug

        # stop and wait for technician to click OK
        mutex().synchronize { thread_status().running = false }
        Thread.stop

        # get technician input and return it
        JSON.parse(job.reload.state, symbolize_names: true).last[:inputs]

      else

        # figure out default technician response
        i = simulated_input_for page
        job.reload.append_step operation: "next", time: Time.now, inputs: i 

        if job.pc > 50
          raise "Job #{jid} executed too many steps (50) in debug mode. Could be an infinite loop."
        end

        i

      end

    end

    def error e

      Job.find(jid).reload.append_step operation: "error", message: e.to_s, backtrace: e.backtrace[0,10]

    end

    def set_task_status task, status

      old_status = task.status
      task.status = status
      task.save validate: false

      if task.errors.empty?
        task.notify "Status changed from '#{old_status}' to '#{status}'.", job_id: jid
      else
        task.notify "Attempt to change status from '#{old_status}' to '#{status}' failed: #{task.full_messages.join(',')}", job_id: jid
      end

      touch = Touch.new
      touch.job_id = jid
      touch.task_id = task.id
      touch.save

      task

    end

    private

    def simulated_input_for page

      i = {}

      page.each do |j|

        if j[:input]

          var = j[:input][:var].to_sym
          dft = j[:input][:default]

          if !dft
            if j[:input][:type] == "text"
              dft = "user input string"
            else
              ddt = 0
            end
          end
          i[var] = dft

        elsif j[:select]

          var = j[:select][:var].to_sym
          dft = j[:select][:default]

          if !dft
            dft = 0
          end

          i[var] = j[:select][:choices][dft]

        end

      end

      i[:timestamp] = 1000*Time.now.to_i

      return i

    end

  end

end
