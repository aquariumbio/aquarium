# typed: true
# frozen_string_literal: true

module Krill

  # Manages execution of a job in debug mode.
  #
  # For threaded execution used in technician interface, see {ThreadedManager}.
  class DebugManager
    # accessible for testing
    attr_reader :sandbox

    # Initializes a {DebugManager} object with the given job.
    #
    # @param job [Job] the job
    # @raise [StandardError] if the job has no operations
    # @raise [KrillSyntaxError] if the job's protocol has a syntax error
    def initialize(job)
      # TODO: change to a named exception
      raise "Error: job #{job.id} has no operations" if job.operations.empty?

      @sandbox = ProtocolSandbox.new(job: job, debug: true)
    end

    # Executes this manager's job.
    #
    # @raise [KrillError, ProtocolError]
    def start
      @sandbox.execute
    end

  end
end
