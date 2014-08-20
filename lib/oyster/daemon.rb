
  #
  # Aquarium metacol daemon
  #
  # This daemon periodically updates all active metacols. 
  #

module MetacolDaemon

  def self.main

    puts "#{Time.now}: Starting Aquarium daemon."

    while true

      sleep 3

      # Build the list of active metacols. The db query (Metacol.where) is in a begin...rescue on the off chance
      # that the db server does not respond to the query, which actually seems to happen once every few days.

      is_valid_query = true

      begin 
        procs = Metacol.where("status = 'RUNNING'")
        l = procs.length # This line forces active record to query the db here, instead of at procs.each below
      rescue Exception => e
        puts "#{Time.now}: Daemon could not get current processes from database server: " + e.message.split('[')[0]
        is_valid_query = false
      end

      if is_valid_query

        procs.each do |process|

          unless process.num_pending_jobs > 10 # to keep poorly written metacols from spiraling out of control
                                               # we limit the number of pending jobs they can have to 11

            # Get the metacol and parse it, checking for parse errors along the way

            if /local_file/ =~ process.sha
              blob = Blob.get process.sha, process.path
              content = blob.xml.force_encoding('UTF-8')
            else
              content = Repo::contents process.path, process.sha
            end

            error = false
            args = (JSON.parse process.state, :symbolize_names => true)[:stack].first

            begin
              m = Oyster::Parser.new(process.path,content).parse args
            rescue Exception => e
              error = true
              process.message = "#{Time.now}: Error in Daemon while parsing #{process.path}: " + e.message.split('[')[0]
              puts process.message
              process.status = "ERROR"
              process.save
            end

            if !error 

              # Parsing was successful, so update the process.

              m.set_state( JSON.parse process.state, :symbolize_names => true )
              m.id = process.id

              begin
                m.update
              rescue Exception => e
                process.message = "#{Time.now}: Error in Daemon on update: " + e.message.split('[')[0]
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

  end

end

