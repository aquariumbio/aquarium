require "rails_helper"
require_relative "workflow"

RSpec.describe "Planner" do

    op_names = [
      "Order Primer",
      "Receive Primer",
      "Make Primer Aliquot",
      "PCR",
      "Run Gel",
      "Extract Fragment",
      "Purify Gel",
      "Gibson Assembly",
      "Transform E coli",
      "Plate E coli",
      "Check E coli Plate",
      "E coli Overnight",
      "Miniprep",
      "Sequencing" ]

  op_names.each do |name|     

    it name do

      puts
      puts "\e[35mTesting Operation '#{name}'\e[39m"

      build_workflow    
      ot = OperationType.find_by_name name  

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
