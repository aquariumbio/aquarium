# frozen_string_literal: true

module Krill

  class DebugManager
    # accessible for testing
    attr_reader :sandbox

    def initialize(job)
      raise "Error: job #{job.id} has no operations" if job.operations.empty?

      @sandbox = ProtocolSandbox.new(job: job, debug: true)
    end

    def start
      @sandbox.execute
    rescue KrillError, ProtocolError => e
      raise e
    rescue Exception => e
      # TODO: determine what other exceptions might happen here and be more specific
      puts "#{@sandbox.job.id}: SERIOUS EXCEPTION #{e}: #{e.backtrace[0, 10]}"

      if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.close
        puts "#{@sandbox.job.id}: Closing ActiveRecord connection"
      end

      raise e
    end

  end
end
