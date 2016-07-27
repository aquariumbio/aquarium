require "rails_helper"
require_relative "workflow"

RSpec.describe "Planner" do

  context "plans" do

    it "works" do

      build_workflow

      gibson = OperationType.find_by_name "Gibson Assembly"

      gop = gibson.operations.create status: "planning"
      gop.set_output("Assembled Plasmid", SampleType.find_by_name("Plasmid").samples.last)
         .set_input("Fragments", SampleType.find_by_name("Fragment").samples.sample(4))
         .set_input("Comp cell", Sample.find_by_name("DH5alpha"))

      puts
      puts "\e[93mPlanning #{gop}\e[39m"

      planner = Planner.new OperationType.all
      planner.plan gop

      puts
      puts "\e[93mMarking shortest plan\e[39m"
      planner.mark_shortest gop

      gop.reload

      puts
      print "\e[93mPlan: "

      issues = gop.issues
      if issues.empty?
        puts "No issues. \e[39"
      else
        puts "Issues: " + issues.join(', ') + " \e[39"
      end

      planner.show gop

    end

  end

end
