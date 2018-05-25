module Krill

  # @api krill
  module Base

    # Returns true if and only if the protocol is bbeing run in debug mode.
    # @return [Boolean]
    def debug
      false
    end

    def show

      page = ShowBlock.new(self).run(&Proc.new)

      # increment pc
      @job ||= Job.find(jid)
      @job.append_step operation: "display", content: page
      # @job.pc += 1
      # @job.save

      if !debug

        # stop and wait for technician to click OK
        mutex().synchronize { thread_status().running = false }
        Thread.stop

        # get technician input
        input = JSON.parse(@job.reload.state, symbolize_names: true).last[:inputs]

        # populate operations with table input data
        input[:table_inputs].each do |ti|
          op = operations.find { |op| op.id == ti[:opid] }
          op.temporary[ti[:key].to_sym] = ti[:value].to_f if op && ti[:type] == 'number'
          op.temporary[ti[:key].to_sym] = ti[:value]      if op && ti[:type] != 'number'
        end

        # return the technician input
        input

      else

        # figure out default technician response
        i = simulated_input_for page
        @job.append_step operation: "next", time: Time.now, inputs: i

        if @job.pc > 500
          raise "Job #{jid} executed too many steps (50) in debug mode. Could be an infinite loop."
        end

        i

      end

    end

    def error e
      Job.find(jid).reload.append_step operation: "error", message: e.to_s, backtrace: e.backtrace[0, 10]
    end

    def set_task_status task, status

      old_status = task.status
      task.status = status
      task.save validate: false

      unless task.errors.empty?
        task.notify "Attempt to change status from '#{old_status}' to '#{status}' failed: #{task.full_messages.join(',')}", job_id: jid
      end

      touch = Touch.new
      touch.job_id = jid
      touch.task_id = task.id
      touch.save

      begin
        task.charge(Job.find(jid), status)
      rescue Exception => e
        puts "Could not charge for task #{task.id}, job #{jid}, '#{status}': #{e.to_s}"
      end

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

        elsif j[:table]

          j[:table].each do |row|
            row.each do |entry|
              if entry.class == Hash && entry[:type]
                op = operations.find { |op| op.id == entry[:operation_id] }
                op.temporary[entry[:key]] = entry[:default] if op
              end
            end
          end

        end

      end

      i[:timestamp] = 1000 * Time.now.to_i

      return i

    end

  end

end
