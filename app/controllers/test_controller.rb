# frozen_string_literal: true

class TestController < ApplicationController

  before_filter :signed_in_user

  # Runs the `ProtocolTest` code for the operation type identified by the
  # parameter.
  #
  # Renders an `AqResponse` object indicating the results of the test,
  # distinguishing between protocol and test errors.
  def run
    response = AqResponse.new
    begin
      operation_type = OperationType.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      response.error('Operation type not found')
              .more(
                error_type: 'error',
                exception_backtrace: e ? e.backtrace : [],
                backtrace: test ? test.backtrace : [],
                log: test ? test.logs : []
              )
      render json: response, status: :ok
      return
    end

    begin
      test = ProtocolTestEngine.run(
        operation_type: operation_type,
        user: current_user
      )
      if test
        response.ok(message: 'test complete',
                    log: test.logs,
                    backtrace: test.backtrace)
      end
    rescue KrillAssertionError => e
      response.error("Assertion failed: #{e.error_message}")
              .more(
                error_type: 'assertion_failure',
                exception_backtrace: e.error_backtrace,
                backtrace: test ? test.backtrace : [],
                log: test ? test.logs : []
              )
    rescue Krill::KrillSyntaxError => e
      response.error(e.error_message)
              .more(
                error_type: 'protocol_syntax_error',
                exception_backtrace: e.error_backtrace,
                backtrace: [], log: []
              )
    rescue Krill::KrillError => e
      response.error(e.error_message)
              .more(
                error_type: 'protocol_error',
                exception_backtrace: e.error_backtrace,
                backtrace: test ? test.backtrace : [],
                log: test ? test.logs : []
              )
    rescue KrillTestSyntaxError => e
      response.error(e.error_message)
              .more(
                error_type: 'test_syntax_error',
                exception_backtrace: e.error_backtrace,
                backtrace: test ? test.backtrace : [],
                log: test ? test.logs : []
              )
    rescue KrillTestError => e
      response.error(e.error_message)
              .more(
                error_type: 'test_error',
                exception_backtrace: e.error_backtrace,
                backtrace: test ? test.backtrace : [],
                log: test ? test.logs : []
              )
    end

    if response.nil?
      # TODO: this should be error status
      response = AqResponse.new.error(
        'Internal error: test completed with no response'
      )
    end

    render json: response, status: :ok
  end

end
