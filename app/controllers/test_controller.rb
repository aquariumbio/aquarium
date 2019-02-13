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

        if pt.error
          resp.error(pt.error)
              .more(backtrace: pt.backtrace, log: pt.logs)
        else
          begin
            pt.analyze
          rescue Exception => e
            resp.error("Test failed: #{e.to_s}")
                .more(backtrace: pt.backtrace, log: pt.logs)
          else
            resp.ok(message: "test complete", 
                        log: pt.logs, 
                  backtrace: pt.backtrace)
          end
        end
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
