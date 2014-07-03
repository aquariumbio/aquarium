require 'socket'              

module Krill

  class Server

    def initialize

      @jobs = {}

    end

    def run

      server = TCPServer.open(3500)

      loop do

        client = server.accept

        begin

          command = JSON.parse client.gets, symbolize_names: true
          jid = command[:jid].to_i

          case command[:operation]

            when "start"

              ph = Manager.new jid

              @jobs[jid] = ph
              client.puts( { response: "ok" }.to_json )
              delete_old_jobs
              puts "Jobs Maintained by Server: #{@jobs.keys}."

            when "continue"

              if @jobs[jid]

                puts "SERVER RECEIVED CONTINUE FOR JOB #{jid}"
                begin
                  @jobs[jid].continue
                rescue Exception => e
                  puts "TRIED TO CONTINUE JOB #{jid}, BUT GOT #{e.to_s} at #{e.backtrace[0,5]}"
                end
                puts "SERVER SENT CONTINUE TO MANAGER FOR JOB #{jid}"
                client.puts( { response: "ok" }.to_json )
                puts "SERVER RESPONDED WITH OK TO CLIENT FOR JOB #{jid}"
  
              else

                j = Job.find(jid)
                j.pc = Job.COMPLETED
                j.save
                client.puts( { response: "error", error: "Krill process not found for job #{jid}" }.to_json )

              end

            else

              client.puts( { response: "error", error: "Unknown command" }.to_json )

          end

        rescue Exception => e

          client.puts( { response: "error", error: e.to_s + ": " + e.backtrace[0,10].to_s }.to_json )

        end

        client.close 

      end

    end

    def delete_old_jobs

      @jobs = @jobs.reject { |k,v| ! v.thread.alive? }

    end

  end

end
