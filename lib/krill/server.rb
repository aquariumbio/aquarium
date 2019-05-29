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
          response = run_command(command: command)
        rescue JSON::ParseError => e
          puts "Error in server command: #{e}"
          message = "Bad format in server command: #{e}"
          response = { response: 'error', error: message }
        end
        client.puts(response.to_json)

        client.close
      end
    end

    private

    # Runs the server command given in the command hash.
    #
    # @param command [Hash] the server command
    # @returns response hash to be sent to the client
    def run_command(command:)
      return { response: 'ok', jobs: @managers.keys } if command[:operation] == 'jobs'
      return { response: 'error', error: 'Expecting job id' } unless command[:jid]

      jid = command[:jid].to_i if command[:jid]
      debug = command[:debug]
      @managers[jid] = Manager.new(jid, debug) if command[:operation] == 'start'

      unless @managers[jid]
        message = "Krill Server: Process not found for job #{jid}."
        return { response: 'error', error: message }
      end

      begin
        status = case command[:operation]
                 when 'start'
                   @managers[jid].run
                 when 'check_again'
                   @managers[job_id].check_again
                 when 'continue'
                   @managers[jid].continue
                 when 'abort'
                   abort(job_id: jid)
                 end
      rescue Exception => e
        # TODO: change to catch manager method exceptions
        message = "Krill Server: #{command[:operation]} on job #{jid} " \
                  "resulted in: #{e}: #{e.backtrace[0, 5]}."
        delete_job(jid)
        return { response: 'error', error: message }
      end

      return { response: 'error', error: "Unknown command #{command[:operation]}" } unless status

      delete_job(jid) if status == 'done'
      { response: status }
    end

    # Stops the manager for the given job ID and deletes if from the manager
    # array.
    #
    # @param job_id [Integer] the job ID
    # @returns the status as 'aborted'
    def abort(job_id:)
      @managers[job_id].stop
      delete_job(job_id)

      'aborted'
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
