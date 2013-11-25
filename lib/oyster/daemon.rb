
  def metacol_daemon

    while true

      sleep 1

      Metacol.where("status = 'RUNNING'").each do |process|

        unless process.num_pending_jobs > 10

          blob = Blob.get process.sha, process.path
          content = blob.xml

          error = false
          begin
            m = Oyster::Parser.new(content).parse
          rescue Exception => e
            error = true
            process.message = "Error parsing #{process.path}: " + e
            puts process.message
            process.status = "ERROR"
            process.save
          end

          if !error

            m.set_state( JSON.parse process.state, :symbolize_names => true )
            m.id = process.id

            begin
              m.update
            rescue Exception => e
              process.message = "On update: " + e.message.split('[')[0]
              puts process.message
              process.status = "ERROR"
              process.save
            end

            process.state = m.state.to_json

            if m.done?
              process.status = "DONE"
            end

            process.save

          end

        end

      end

    end

  end

