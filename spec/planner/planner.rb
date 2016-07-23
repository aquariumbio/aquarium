require "rails_helper"
require_relative "workflow"

RSpec.describe "Planner" do

  context "plans" do

    it "works" do

      build_workflow

      puts "- Instantiating Output Operation (Gibson Assembly)"

      gibson = OperationType.find_by_name "Gibson Assembly"

      gop = gibson.operations.create status: "planning"
      gop.set_output("Assembled Plasmid", SampleType.find_by_name("Plasmid").samples.last)
         .set_input("Fragments", SampleType.find_by_name("Fragment").samples.sample(2))

      puts "\e[95mPlanning #{gop}\e[39m"

      planner = Planner.new OperationType.all
      planner.plan gop

      puts
      puts "Plan"
      planner.show gop

    end

  end

end
