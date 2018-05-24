require 'rails_helper'

RSpec.describe 'Planner' do

  OperationType.all.collect(&:name).each do |name|

    it name do

      puts
      puts "\e[93mTesting operation '#{name}'\e[39m"

      # build_workflow
      ot = OperationType.find_by name: name

      ops = ot.random(5)
      puts "\e[93mMade five random operations\e[39m"
      ops.each do |op|
        puts "  #{op}"
      end

      job = ot.schedule(ops, User.find_by(login: 'klavins'), Group.find_by(name: 'technicians'))
      puts "\e[93mScheduled job #{job.id}\e[39m"

      job.user_id = User.find_by(login: 'klavins').id
      job.save

      puts "\e[93mStarting job #{job.id}\e[39m"
      puts

      manager = Krill::Manager.new job.id, true, 'master', 'master'
      manager.run

      puts "\e[93mBacktrace\e[39m"
      job.reload
      job.backtrace.each do |step|
        puts step
      end

    end

  end

end
