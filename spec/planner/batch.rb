require "rails_helper"
require_relative "gibson"

RSpec.describe "Planner" do

  context "plans" do

    it "makes plans" do

      # build_workflow      

      gibson = OperationType.find_by_name "Gibson Assembly"
      pcr = OperationType.find_by_name "PCR"

      common_fragment = SampleType.find_by_name("Fragment").samples.sample

      ops = (1..4).collect { |i| 

        gop = gibson.operations.create status: "planning", user_id: User.find_by_login("klavins").id
        
        gop.set_output("Assembled Plasmid", SampleType.find_by_name("Plasmid").samples.last)
           .set_input("Fragments", SampleType.find_by_name("Fragment").samples.sample(2) << common_fragment )
           .set_input("Comp cell", Sample.find_by_name("DH5alpha"))

        gop

      }

      planner = Planner.new OperationType.all
      planner.plan_trees ops

      ops.each do |op|
        puts
        puts "\e[92mPlan #{op.plan.id} issues: [ " + op.issues.join(', ') + "]\e[39m"      
        op.show_plan
      end

    end

  end

end

