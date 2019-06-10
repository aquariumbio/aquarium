# frozen_string_literal: true

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
          command = JSON.parse(client.gets, symbolize_names: true)
          run_command(command: command, client: client)
        rescue JSON::ParseError => e
          puts "Error parsing Krill client command: #{e}"
          puts e.backtrace
          client.puts({ response: 'error', error: e.to_s + ': ' + e.backtrace[0, 10].to_s }.to_json)
        rescue StandardError => e
          # TODO: consider how to refine the error handling
          # e.g., SystemCallError would handle all system socket errors
          puts "Exception #{e}"
          puts e.backtrace
          client.puts({ response: 'error', error: e.to_s + ': ' + e.backtrace[0, 10].to_s }.to_json)
        end

        client.close
      end
    end

    def run_command(command:, client:)
      if command[:operation] == 'jobs'
        client.puts(response: 'ok', jobs: @managers.keys)
        return
      end

      unless command[:jid]
        client.puts(response: 'error', error: 'Expecting job id')
        return
      end

      jid = command[:jid].to_i if command[:jid]
      debug = command[:debug]
      @managers[jid] = Manager.new(jid, debug) if command[:operation] == 'start'

      unless @managers[jid]
        message = "Krill Server: Process not found for job #{jid}."
        client.puts(response: 'error', error: message)
        return
      end

      if command[:operation] == 'abort'
        @managers[jid].stop
        delete_job(job_id: jid)
        client.puts({ response: 'aborted' }.to_json)
        return
      end

      unless %w[start continue check_again].member?(command[:operation])
        client.puts({ response: 'error', error: 'Unknown command' }.to_json)
        return
      end

      begin
        status = @managers[jid].send(command[:operation])
        delete_job(job_id: jid) if status == 'done'
        client.puts({ response: status }.to_json)
      rescue StandardError => e
        # TODO: change to catch manager method exceptions
        message = "Krill Server: #{command[:operation]} on job #{jid} " \
                  "resulted in: #{e}: #{e.backtrace[0, 5]}."
        client.puts(response: 'error', error: message)
        delete_job(jid)
      end
    end

    # Deletes the manager for the given job ID from the manager array.
    #
    # @param job_id [Integer] the job ID
    def delete_job(job_id:)
      @managers.delete(job_id)
    end

    # TODO: verify this is dead code
    def delete_old_jobs
      @managers = @managers.select { |_k, v| v.thread.alive? }
    end
  end
end
