require 'socket'              

module Krill

  class Server

    def initialize
      @managers = {}
    end

    def run

      server = TCPServer.open(3500)

      loop do

        client = server.accept

        begin

          command = JSON.parse client.gets, symbolize_names: true
          jid = command[:jid].to_i if command[:jid]

          case command[:operation]

            when "start" #######################################################################################################

              @managers[jid] = Manager.new jid

              begin

                status = @managers[jid].run

              rescue Exception => e

                client.puts( { response: "error", error: "Krill Server: #{command[:operation]} resulted in: #{e.to_s}: #{e.backtrace[0,5]}" }.to_json )
                @managers.delete(jid)

              else

                @managers.delete(jid) if status == "done"
                client.puts( { response: status }.to_json )

              end

            when "continue", "check_again" #####################################################################################

              if @managers[jid]

                begin

                  status = @managers[jid].send(command[:operation])

                rescue Exception => e

                  str = "Krill Server: #{command[:operation]} on job #{jid} resulted in: #{e.to_s}: #{e.backtrace[0,5]}."
                  client.puts( { response: "error", error: str }.to_json )
                  @managers.delete(jid)

                else      

                  @managers.delete(jid) if status == "done"
                  client.puts( { response: status }.to_json )

                end

              else

                client.puts( { response: "error", error: "Krill Server: Process not found for job #{jid}." }.to_json )

              end

            when "abort" #######################################################################################################

              if @managers[jid]

                @managers[jid].stop
                @managers.delete(jid)
                client.puts( { response: "aborted" }.to_json )

              else 

                client.puts( { response: "error", error: "Could not find job #{jid}" }.to_json )

              end

            when "jobs" ########################################################################################################

              client.puts( { response: "ok", jobs: @managers.keys }.to_json )

            when "kill zombies" ################################################################################################

              killed = []

              Job.where('pc >= 0').each do |j|

                unless @managers[j.id] 
                  j.pc = -2
                  j.save
                  killed.push(j.id)
                end

              end

              client.puts( { response: "ok", killed: killed }.to_json )

            else # Uknown command ##############################################################################################

              client.puts( { response: "error", error: "Unknown command" }.to_json )

          end

        rescue Exception => e

          client.puts( { response: "error", error: e.to_s + ": " + e.backtrace[0,10].to_s }.to_json )

        end

        client.close 

      end

    end

    def delete_old_jobs

      @managers = @managers.reject { |k,v| ! v.thread.alive? }

    end

  end

end
