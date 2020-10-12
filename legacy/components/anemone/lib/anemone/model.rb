# frozen_string_literal: true

# typed: false

module Anemone

  class Worker < ActiveRecord::Base

    before_save :defaults

    def defaults
      self.status ||= 'uninitialized'
    end

    def yo
      puts 'yo yo'
    end

    def run

      raise 'Error: Worker already has been run' unless self.status == 'uninitialized'

      worker = self
      worker.status = 'running'
      worker.save

      Thread.new do

        yield
      rescue StandardError => e
        ActiveRecord::Base.transaction do
          worker.reload
          worker.status = 'error'
          worker.message = (e.to_s + ': ' + e.backtrace[0..2].join(', '))[0..254]
          worker.save
        end
        raise "Error: Could not save worker #{worker.id} status: #{worker.errors.full_messages.join(', ')}" if worker.errors.any?
      else
        ActiveRecord::Base.transaction do
          worker.reload
          worker.status = 'done'
          worker.save
        end

      end

    end

    self

  end

end
