
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
        Rails.logger.info "Worker #{worker.id} about to start"
        Rails.logger.info "Worker #{worker.id} starting 1"
        worker.status = "running"
        worker.save
        Rails.logger.info "Worker #{worker.id} starting 2"

        Thread.new do

          begin
            Rails.logger.info "Worker #{worker.id} about to yeild"
            yield
            Rails.logger.info "Worker #{worker.id} yeilded"
          rescue Exception => e
            Rails.logger.error "Worker #{worker.id} failed: #{e}"
            Rails.logger.info "worker = #{worker.inspect}"
            worker.status = "error"
            worker.message = e.to_s
            worker.save
          else
            Rails.logger.info "Worker #{worker.id} succeeded."
            worker.status = "done"
            worker.save
          end

        end

      else

        raise "Error: Worker #{worker.id} already has been run"

      end

    end

    self

  end

end
