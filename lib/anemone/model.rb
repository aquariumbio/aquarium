
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
        worker.status = "running"
        worker.save

        Thread.new do

          begin
            yield
          rescue Exception => e
            worker.status = "error"
            worker.message = e.to_s + ": " + e.backtrace[0..2].join(", ")
            worker.save
            if worker.errors.any?
              raise "Error: Could not save worker #{worker.id} status: #{worker.errors.full_messages.join(', ')}"
            end
          else
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
