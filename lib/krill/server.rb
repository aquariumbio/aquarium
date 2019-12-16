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
        rescue JSON::ParserError => e
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

    # Run the specified command and send result to client.
    #
    # Note: all messages to client should be JSON.
    #
    # @param command [String] the name of the command
    # @param client [Client] the Krill client object
    def run_command(command:, client:)
      if command[:operation] == 'jobs'
        client.puts({ response: 'ok', jobs: @managers.keys }.to_json)
        return
      end

      unless command[:jid]
        client.puts({ response: 'error', error: 'Expecting job id' }.to_json)
        return
      end

      jid = command[:jid].to_i if command[:jid]
      begin
        job = Job.find(jid)
      rescue ActiveRecord::RecordNotFound
        client.puts({ response: 'error', error: "Job #{jid} not found" }.to_json)
        return
      end

      begin
        @managers[jid] = ThreadedManager.new(job) if command[:operation] == 'start'
      rescue Krill::KrillBaseError => e
        client.puts({ response: 'error', error: e.error_message, backtrace: e.error_backtrace }.to_json)
        return
      rescue StandardError => e
        client.puts({ response: 'error', error: e.to_s, backtrace: e.backtrace }.to_json)
        return
      end

      unless @managers[jid]
        message = "Krill Server: Process not found for job #{jid}."
        client.puts({ response: 'error', error: message }.to_json)
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
      rescue Krill::KrillBaseError => e
        client.puts({
          response: 'error',
          error: e.error_message,
          backtrace: e.error_backtrace
        }.to_json)
        delete_job(job_id: jid)
      rescue StandardError => e
        # TODO: change to catch manager method exceptions
        message = "Krill Server: #{command[:operation]} on job #{jid} " \
                  "resulted in: #{e}: #{e.backtrace[0, 5]}."
        client.puts({ response: 'error', error: message }.to_json)
        delete_job(job_id: jid)
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
      @managers = @managers.select { |_k, manager| manager.alive? }
    end
  end
end
