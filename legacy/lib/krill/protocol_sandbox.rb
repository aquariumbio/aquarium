# typed: false
# frozen_string_literal: true

module Krill
  # TODO: Look at using https://github.com/ukutaht/safe_ruby here

  # Defines an execution environment for the protocol of a job.
  # Loads the protocol into a unique namespace module, and extends the class
  # with protocol base methods.
  #
  # Despite the name, this is not yet a sandbox, so protocols may still
  # do bad, bad things to the server environment.
  class ProtocolSandbox
    # these are here for observability in tests
    attr_reader :job, :protocol

    delegate :debug, to: :protocol
    delegate :reload, to: :job

    # Initializes a new {ProtocolSandbox} object.
    #
    # @param job [Job] the job
    # @param debug [TrueClass, FalseClass] whether protocol runs in debug mode
    # @param mutex [Mutex] lock object for synchronization (nil)
    # @param thread_status [ThreadStatus] status for manager thread (nil)
    # @raise [KrillSyntaxError] if the protocol has a syntax error
    # @raise [KrillError] if loading the protocol has an execution error
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
      @namespace_name = "#{namespace_prefix}#{suffix}"
      namespace = Krill.make_namespace(name: @namespace_name)
      namespace.add(code: operation_type.protocol)
      namespace::Protocol.include(base_class)
      @protocol = namespace::Protocol.new
    rescue SyntaxError => e
      raise KrillSyntaxError.new(operation_type: operation_type, error: e)
    rescue StandardError, NoMemoryError, ScriptError, SecurityError, SystemExit, SystemStackError => e
      raise KrillError.new(job: job, error: e, namespace: @namespace_name)
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

        raise KrillError.new(job: @job, error: e, namespace: @namespace_name)
      ensure
        @job.save
      end
    end

    # Indicates whether the job has completed.
    #
    # @return [TrueClass, FalseClass] true if the job is complete, otherwise false
    def done?
      @job.done?
    end

    private

    # Creates a new module derived from {Krill::Base} and adds
    # methods `jid`, `input`, and `debug`.
    #
    # @param name [String] the name for the new module
    # @param debug [Boolean] whether to run in debug mode
    # @return the constructed base module
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
    # @return the unique random string
    def generate_suffix(length:, prefix:)
      loop do
        suffix = SecureRandom.urlsafe_base64(length, false).gsub('-', '')
        return suffix unless Object.const_defined?("#{prefix}#{suffix}")
      end
    end
  end

  # Exception class for protocol errors
  class ProtocolError < StandardError
    def initialize(message)
      super(message)
    end
  end

  class KrillBaseError < StandardError
    attr_reader :operation_type, :error, :namespace

    # Create a KrillBaseError object for the given operation type, error and message.
    #
    # @param operation_type [OperationType] the operation type
    # @param error [Exception] the error object
    # @param message [string] the message for this error
    def initialize(operation_type:, error:, message:, namespace: '')
      @operation_type = operation_type
      @error = error
      @namespace = namespace
      super(message)
    end

    # Returns the path of the operation type for this error.
    def operation_path
      "#{@operation_type.category}/#{@operation_type.name}"
    end

    # Returns a transformed version of the message for the error of this object.
    # Replaces occurrences of "(eval)" with the operation type path, and
    # removes suffix referencing ExecutionNamespace enclosing the protocol
    # during execution.
    def error_message
      messages = []
      @error.message.each_line do |line|
        # replaces occurrence of "(eval)" as file path
        match = line.match(/^\(eval\):(\d+):(.+)$/m)
        if match
          line_number, message = match.captures
          messages.append("#{operation_path}: line #{line_number}:#{message}")
          next
        end

        # strips uninformative context from NameError message
        namespace_pattern = Regexp.new(" for (\#<)?#{@namespace}:(Module|0x[0-9a-f]+>)$")
        match = line.match(namespace_pattern)
        if match
          loc = match.begin(0) - 1
          messages.append(line[0..loc])
          next
        end

        messages.append(line)
      end

      messages.join('')
    end

    # Returns the backtrace of the associated error filtered to exclude
    # Aquarium context.
    # Replaces occurrences of '(eval)' path with operation type path.
    def error_backtrace
      split = error.backtrace.collect { |msg| msg.match(/^([^:]+):(\d+):(.+)$/m).captures }
      filtered = split.reject { |c| c.first.match(%r{^(/[^/]+)+$}m) }
      filtered.collect do |captures|
        path, line_number, message = captures
        path = operation_path if path == '(eval)'

        "#{path}: line #{line_number}: #{message.strip}".strip
      end
    end
  end

  # Exception class for errors during execution of protocols
  class KrillError < KrillBaseError
    attr_reader :job

    # Create a KrillError object for the given job and exception with an
    # optional message.
    #
    # @param job [Job] the job where error occurred
    # @param error [Exception] the error
    # @param message [String] the error message
    def initialize(job:, error:, message: 'Error executing protocol', namespace: '')
      @job = job
      super(
        operation_type: @job.operation_type,
        error: error,
        message: message,
        namespace: namespace
      )
    end

  end

  # Exception class for protocol syntax errors
  class KrillSyntaxError < KrillBaseError

    # Create a KrillSyntaxError object indicating an error in the given
    # operation type.
    #
    # @param operation_type [OperationType] the operation type
    # @param error [Exception] the error object
    # @param message [String] the error message
    def initialize(operation_type:, error:, message: 'Syntax error in operation type')
      super(operation_type: operation_type, error: error, message: message)
    end
  end

end
