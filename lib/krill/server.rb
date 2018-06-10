

require 'socket'

module Krill

  class Server

    def initialize
      @managers = {}
    end

    def run(port)

      puts "Starting Krill Server on port #{port} at #{Time.now}"

      server = TCPServer.open(port)

      loop do

        client = server.accept

        begin
          command = JSON.parse client.gets, symbolize_names: true
          jid = command[:jid].to_i if command[:jid]
          debug = command[:debug]
          directory = command[:directory]
          branch = command[:branch]

          case command[:operation]

          when 'start' #######################################################################################################

            @managers[jid] = Manager.new jid, debug, directory, branch

            begin
              status = @managers[jid].run
            rescue Exception => e
              puts "Exception sent to client: #{e}: #{e.backtrace[0, 5]}"
              client.puts({ response: 'error', error: "Krill Server: #{command[:operation]} resulted in: #{e}: #{e.backtrace[0, 5]}" }.to_json)
              @managers.delete(jid)
            else
              @managers.delete(jid) if status == 'done'
              client.puts({ response: status }.to_json)
            end

          when 'continue', 'check_again' #####################################################################################

            if @managers[jid]

              begin
                status = @managers[jid].send(command[:operation])
              rescue Exception => e
                str = "Krill Server: #{command[:operation]} on job #{jid} resulted in: #{e}: #{e.backtrace[0, 5]}."
                client.puts({ response: 'error', error: str }.to_json)
                @managers.delete(jid)
              else
                @managers.delete(jid) if status == 'done'
                client.puts({ response: status }.to_json)
              end

            else

              client.puts({ response: 'error', error: "Krill Server: Process not found for job #{jid}." }.to_json)

            end

          when 'abort' #######################################################################################################

            if @managers[jid]

              @managers[jid].stop
              @managers.delete(jid)
              client.puts({ response: 'aborted' }.to_json)

            else

              client.puts({ response: 'error', error: "Could not find job #{jid}" }.to_json)

            end

          when 'jobs' ########################################################################################################

            client.puts({ response: 'ok', jobs: @managers.keys }.to_json)

          else # Uknown command ##############################################################################################

            client.puts({ response: 'error', error: 'Unknown command' }.to_json)

          end
        rescue Exception => e
          client.puts({ response: 'error', error: e.to_s + ': ' + e.backtrace[0, 10].to_s }.to_json)
        end

        client.close

      end

    end

    def delete_old_jobs

      @managers = @managers.select { |_k, v| v.thread.alive? }

    end

  end

end
