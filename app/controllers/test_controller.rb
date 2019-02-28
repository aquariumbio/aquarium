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

        if pt.job.error?
          resp.error("Protocol error: #{pt.job.error_message}")
              .more(backtrace: pt.job.error_backtrace, log: [])
        else
          begin
            pt.analyze
          rescue Minitest::Assertion => e
            resp.error("Test failed: #{e.to_s}")
                .more(
                  exception_backtrace: e ? e.backtrace : [], 
                  backtrace: pt ? pt.backtrace : [], 
                  log: pt ? pt.logs : [])
          else
            resp.ok(message: "test complete", 
                        log: pt.logs, 
                  backtrace: pt.backtrace)
          end
        end
      rescue StandardError => error
        resp.error("Test error: #{error.to_s}")
            .more(exception_backtrace: error.backtrace,
                  backtrace: [], log: [])
      rescue Exception => e
        resp.error(e.to_s)
            .more(
              exception_backtrace: e ? e.backtrace : [], 
              backtrace: pt ? pt.backtrace : [], 
              log: pt ? pt.logs : [])
      end

      raise ActiveRecord::Rollback

    end

    render json: resp

  end

end
