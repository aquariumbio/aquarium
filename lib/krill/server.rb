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

            when "start"

              @managers[jid] = Manager.new jid
              @managers[jid].run

              client.puts( { response: "ok" }.to_json )

              delete_old_jobs
              puts "Jobs Maintained by Server: #{@managers.keys}."

            when "continue"

              if @managers[jid]

                begin
                  alive = @managers[jid].continue
                rescue Exception => e
                  puts "TRIED TO CONTINUE JOB #{jid}, BUT GOT #{e.to_s}: #{e.backtrace[0,5]}"
                end

                if alive
                  client.puts( { response: "ok" }.to_json )
                else
                  j = Job.find(jid)
                  j.pc = Job.COMPLETED
                  j.save
                  client.puts( { response: "error", error: "Krill thread job #{jid} died unexpectedly" }.to_json )
                end
  
              else

                j = Job.find(jid)
                j.pc = Job.COMPLETED
                j.save

                client.puts( { response: "error", error: "Krill process not found for job #{jid}" }.to_json )

              end

            when "kill zombies"

              killed = []

              Job.where('pc >= 0').each do |j|

                unless @managers[jid] 
                  j.pc = -2
                  j.save
                  killed.push(j.id)
                end

              end

              client.puts( { response: "ok", killed: killed }.to_json )

            else # Uknown command

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
