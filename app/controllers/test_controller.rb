require "minitest"

class TestController < ApplicationController

  before_filter :signed_in_user

  # Runs the `ProtocolTest` code for the operation type identified by the
  # parameter.
  #
  # Renders an `AqResponse` object indicating the results of the test,
  # distinguishing between protocol and test errors.
  def run
    operation_type = OperationType.find(params[:id])
    resp = nil

    ActiveRecord::Base.transaction do
      begin
        resp = load_test(code: operation_type.test.content)
        if resp.nil?
          test = ProtocolTest.new(operation_type, current_user)
          resp = pre_test(test: test)
          if resp.nil?
            resp = run_test(test: test)
            if resp.nil?
              resp = post_test(test: test)
            end
          end
        end
      rescue Exception => e
        resp = AqResponse.new
        resp.error(e.to_s)
            .more(
              error_type: 'error',
              exception_backtrace: e ? e.backtrace : [], 
              backtrace: test ? test.backtrace : [], 
              log: test ? test.logs : []
            )
      end
      raise ActiveRecord::Rollback
    end

    if resp.nil?
      resp = AqResponse.new.error(
        'Internal error: test completed with no response'
      )
    end

    render json: resp
  end

  # Loads the test code.
  #
  # @param code [Code] the test code object
  # @return [AqResponse] if an exception occurs, and `nil` otherwise
  def load_test(code:)
    begin
      resp = nil
      eval(code)
    rescue SyntaxError, StandardError => error
      resp = handle_error(error: error, phase_name: 'test loading')
    end

    resp    
  end

  # Runs the test `setup` method.
  #
  # @param test [ProtocolTest] the test object
  # @return [AqResponse] if an exception occurs, and `nil` otherwise
  def pre_test(test:)
    begin
      resp = nil
      test.setup
      unless test.operations_present?
        resp = AqResponse.new
        resp.error("Test error: setup must add operations")
      end
    rescue SystemStackError, SyntaxError, StandardError => error
      resp = handle_error(error: error, logs: test.logs)
    end

    resp
  end

  # Runs the protocol under test.
  #
  # @param test [ProtocolTest] the test object
  # @return [AqResponse] if an exception occurs, and `nil` otherwise
  def run_test(test:)
    begin
      resp = nil
      test.run
      if test.error?
        resp = AqResponse.new
        resp.error("Protocol error: #{test.error_message}")
            .more(exception_backtrace: test.error_backtrace,
                  log: test.logs)
      end
    rescue SystemStackError, SyntaxError, StandardError => error
      resp = handle_error(error: error, logs: test.logs)
    end
  
    resp 
  end

  # Runs the test `analyze` method.
  #
  # @param test [ProtocolTest] the test object
  # @return [AqResponse] if the protocol has an error, and `nil` otherwise
  def post_test(test:)
    begin
      resp = AqResponse.new
      test.analyze
    rescue Minitest::Assertion => error
      error_trace = filter_backtrace(backtrace: error.backtrace)
                    .map { |message| translate_trace(message: message) }
      resp.error("Assertion failed: #{error.to_s}")
          .more(
            error_type: 'assertion_failure',
            exception_backtrace: error_trace, 
            backtrace: test ? test.backtrace : [], 
            log: test ? test.logs : []
          )
    rescue SystemStackError, SyntaxError, StandardError => error
      resp = handle_error(error: error)
    else
      resp.ok(message: "test complete", 
              log: test.logs, 
              backtrace: test.backtrace)
    end
  
    resp
  end

  # Creates an `AqResponse` object for an error that occur in a test.
  # Filters backtrace to include errors that occur within an `(eval)`.
  #
  # @param error [StandardError, SyntaxError, SystemStackError] the exception object
  # @return [AqResponse] object with error message, and backtrace.
  def handle_error(error:, phase_name: nil, logs: [])
    resp = AqResponse.new
    error_trace = filter_backtrace(backtrace: error.backtrace)
                  .map { |message| translate_trace(message: message) }
    error_message = if error_trace[-1].present?
                      "Error in #{error_trace[-1]}: #{error.to_s}"
                    elsif (error.is_a? SyntaxError) && error.message.match(/^\(eval\):\d+: .+$/)
                      line_number, message = error.message.match(
                        /^\(eval\):(\d+): (.+)$/
                      ).captures
                      "Test line #{line_number}: #{message}"
                    elsif phase_name.present?
                      "Error during #{phase_name}: #{error.message}"
                    else
                      "Error #{error.class} #{error.message}"
                    end
    resp.error(error_message)
        .more(
          error_type: 'test_error',
          exception_backtrace: error_trace,
          backtrace: [], log: logs
        )

    resp
  end

  # Filters the given backtrace for error messages that occur within an `(eval)`.
  #
  # @param backtrace [Array<String>] the backtrace to filter
  # @return [Array<String>] the filtered backtrace
  def filter_backtrace(backtrace:)
    backtrace.reject { |msg| msg.match(/^\(eval\):\d+:in `.+'$/).nil? }.uniq
  end

  # Translates an error message of the form
  #   (eval):10:in `method'
  # to a message with just the method name and line number.
  #
  # @param message [String] the error message matching `eval` error pattern
  # @return [String] object containing the method name and line number
  def translate_trace(message:)
    line_number, method = message.match(/^\(eval\):(\d+):in `(.+)'$/).captures

    "`#{method}` (line #{line_number})"
  end

end
