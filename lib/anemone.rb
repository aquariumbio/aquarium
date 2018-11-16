require "anemone/version"
require "anemone/railtie" if defined?(Rails)

#
# Usage:
# worker = Worker.new name: "MyWorker"
# worker.save
#
# worker.run do
#  # A complex job
# end // returns immediately
#
# worker.reload.status
#
# w = Worker.find(worker.id)
# w.status
#
# w = Anemone::Worker.new name: "try"; w.save; w.run do; x = 1/0; end; w.reload
#
module Anemone

  class Worker < ActiveRecord::Base

    before_save :defaults

    def defaults
      self.status ||= "uninitialized"
    end

    def yo
      puts "yo yo"
    end

    def run

      if self.status == "uninitialized"

        worker = self

        Thread.new do

          worker.status = running
          worker.save

          begin
            yield
          rescue Exception => e
            Rails.logger.error "Worker failed: #{e}"
            Rails.logger.info "worker = #{worker.inspect}"
            worker.status = "error"
            worker.message = e.to_s
            worker.save
          else
            Rails.logger.info "Worker succeeded."
            worker.status = "done"
            worker.save
          end

        end

      else

        raise "Error: Worker already has been run"

      end

    end

    self

  end

end
