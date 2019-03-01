require "minitest"

class TestController < ApplicationController

  before_filter :signed_in_user

  def run

    resp = AqResponse.new      
 
    ot = OperationType.find(params[:id])
    code = ot.code("test").content

    ActiveRecord::Base.transaction do

      begin
        eval(code)
        pt = ProtocolTest.new ot, current_user

        pt.setup
        pt.run

        if pt.error?
          resp.error("Protocol error: #{pt.error_message}")
              .more(backtrace: pt.error_backtrace, log: [])
        else
          begin
            pt.analyze
          rescue Minitest::Assertion => error
            error_trace = filter_backtrace(backtrace: error.backtrace)
                          .map { |message| translate_trace(message: message) }
            resp.error("Assertion failed: #{error.to_s}")
                .more(
                  error_type: 'assertion_failure',
                  exception_backtrace: error_trace, 
                  backtrace: pt ? pt.backtrace : [], 
                  log: pt ? pt.logs : []
                )
          else
            resp.ok(message: "test complete", 
                    log: pt.logs, 
                    backtrace: pt.backtrace)
          end
        end
      rescue SystemStackError, SyntaxError, StandardError => error
        handle_error(error: error, response: resp)
      rescue Exception => e
        resp.error(e.to_s)
            .more(
              error_type: 'error',
              exception_backtrace: e ? e.backtrace : [], 
              backtrace: pt ? pt.backtrace : [], 
              log: pt ? pt.logs : []
            )
      end

      raise ActiveRecord::Rollback

    end

    render json: resp

  end

  def handle_error(error:, response:)
    error_trace = filter_backtrace(backtrace: error.backtrace)
                  .map { |message| translate_trace(message: message) }
    error_message = "Error in #{error_trace[-1]}: #{error.to_s}"
                    
    response.error(error_message)
            .more(
              error_type: 'test_error',
              exception_backtrace: error_trace,
              backtrace: [], log: []
            )
  end

  # Filters the backtrace for eval lines
  def filter_backtrace(backtrace:)
    backtrace.reject { |msg| msg.match(/^\(eval\):\d+:in `.+'$/).nil? }.uniq
  end

  def translate_trace(message:)
    line_number, method = message.match(/^\(eval\):(\d+):in `(.+)'$/).captures

    "`#{method}` (line #{line_number})"
  end

end
