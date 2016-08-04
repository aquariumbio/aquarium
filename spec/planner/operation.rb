require "rails_helper"
require_relative "workflow"

RSpec.describe "Planner" do

  context "plans" do

    it "runs operations" do

      build_workflow

      ot = OperationType.all.sample
      ops = ot.random(5)
      puts "Made five random operations of type #{ot.name}"
      ops.each do |op|
        puts "  #{op}"  
      end

      job = ot.schedule(ops, User.find_by_login('klavins'), Group.find_by_name('technicians'))
      puts "Scheduled job #{job.id}"

      job.user_id = User.find_by_login('klavins').id
      job.save

      puts "  Starting job #{job.id}"
      manager = Krill::Manager.new job.id, true, "master", "master"
      manager.run

    end

  end

end
