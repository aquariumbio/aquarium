# frozen_string_literal: true

namespace :cleanup do

  desc 'Clean up various things in ways that are hard to do with the UI'

  task running_metacols: :environment do
    n = 0
    Metacol.where(status: 'RUNNING').each do |m|
      m.status = 'DONE'
      m.save
      m.jobs.select { |j| j.pc == Job.NOT_STARTED }.each do |j|
        j.pc = Job.COMPLETED
        j.save
        n += 1
      end
    end
    puts "#{n} metacols and their corresponding jobs canceled!"
  end

end
