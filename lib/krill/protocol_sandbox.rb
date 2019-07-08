# frozen_string_literal: true

module Krill
  # Look at using https://github.com/ukutaht/safe_ruby here
  class ProtocolSandbox
    # these are here for observability in tests
    attr_reader :job, :protocol

    delegate :debug, to: :protocol
    delegate :reload, to: :job

    # Initializes a new {ProtocolSandbox} object
    def initialize(job:, debug: false, mutex: nil, thread_status: nil)
      @job = job
      operation_type = @job.operation_type
      base_class_prefix = 'KrillProtocolBase'
      namespace_prefix = 'ExecutionNamespace'
      suffix = generate_suffix(length: 32, prefix: base_class_prefix)
      base_class_name = "#{base_class_prefix}#{suffix}"
      base_class = make_base(
        name: base_class_name,
        debug: debug,
        mutex: mutex,
        thread_status: thread_status
      )

      namespace = Krill.make_namespace(name: "#{namespace_prefix}#{suffix}")
      namespace.add(code: operation_type.protocol)
      namespace::Protocol.include(base_class)
      @protocol = namespace::Protocol.new
    rescue SyntaxError => e

      line_number, message = e.message.match(/^\(eval\):(\d+): (.+)$/m).captures
      message = "#{operation_type.category}/#{operation_type.name}: line #{line_number}: #{message}".strip
      # TODO: fix this so captures code; currently getting lost
      raise KrillSyntaxError.new(operation_type: operation_type, error: e, message: message)
    end

    # Executes `protocol.main` for the job.
    #
    # Captures the return value, and the following exceptions:
    # - NoMemoryError occurs if allocation exceeds allowed storage (e.g., string larger than max capacity)
    # - ScriptError
    # - SecurityError
    # - StandardError
    # - SystemExit
    # - SystemStackError
    #
    # @raise [KrillError] if one of the exceptions above is caught
    def execute
      @job.start
      begin
        return_value = @protocol.main
        @job.reload
        @job.append_step(operation: 'complete', rval: return_value)
        @job.stop('done')
      rescue StandardError, NoMemoryError, ScriptError, SecurityError, SystemExit, SystemStackError => e
        puts "#{@job.id}: EXCEPTION #{e}"
        puts e.backtrace[0, 10]
        @job.reload
        @job.stop('error')
        @job.append_step(operation: 'error', message: e.to_s, backtrace: e.backtrace[0, 10])
        @job.append_step(operation: 'next', time: Time.zone.now, inputs: {})
        @job.append_step(operation: 'aborted', rval: {})
        raise KrillError.new(job: @job, error: e)
      ensure
        @job.save
      end
    end

    def done?
      @job.pc == Job.COMPLETED
    end

    private

    # Creates a new module derived from {Krill::Base} and adds
    # methods `jid`, `input`, and `debug`.
    #
    # @param name [String] the name for the new module
    # @param debug [Boolean] whether to run in debug mode
    # @returns the constructed base module
    def make_base(name:, debug:, mutex:, thread_status:)
      b = Object.const_set(name, Module.new)
      b.send(:include, Base)
      b.module_eval("def jid; #{@job.id}; end", 'generated_base')
      initial_state = @job.job_state
      args = initial_state[0][:arguments]
      b.module_eval("def input; #{args}; end", 'generated_base')
      b.module_eval("def debug; #{debug}; end", 'generated_base')

      manager_mutex = mutex
      b.send :define_method, :mutex do
        manager_mutex
      end

      manager_thread_status = thread_status
      b.send :define_method, :thread_status do
        manager_thread_status
      end

      b
    end

    # Generate a random string that has not been used as a suffix for the name
    # of an existing constant.
    #
    # @param length [Integer] the max length of the string to generate
    # @param prefix [String] the prefix to use to check for existing constants
    # @returns the unique random string
    def generate_suffix(length:, prefix:)
      loop do
        suffix = SecureRandom.urlsafe_base64(length, false).gsub('-', '')
        return suffix unless Object.const_defined?("#{prefix}#{suffix}")
      end
    end
  end

  class ProtocolError < StandardError
    def initialize(message)
      super(message)
    end
  end

  class KrillError < StandardError
    attr_reader :job, :error

    # Create a KrillError object for the given job and exception with an
    # optional message.
    #
    # @param job [Job] the job where error occurred
    # @param error [Exception] the error
    # @param message [String] the error message
    def initialize(job:, error:, message: 'Error executing protocol')
      @job = job
      @error = error
      super(message)
    end
  end

  class KrillSyntaxError < StandardError
    attr_reader :operation_type, :error

    # Create a KrillSyntaxError object indicating an error in the given
    # operation type.
    #
    # @param operation_type [OperationType] the operation type
    # @pram
    def initialize(operation_type:, error:, message: 'Syntax error in operation type')
      @operation_type = operation_type
      @error = error
      super(message)
    end
  end

end
