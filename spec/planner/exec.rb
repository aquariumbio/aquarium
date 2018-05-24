require "rails_helper"
require_relative "gibson"
require_relative "runner"

RSpec.describe "Planner" do

  context "plans" do

    it "executes plans" do

      # build_workflow

      # do some planning
      (1..6).each do |_i|

        gop = plan_gibson 2

        puts
        print "\e[93mPlan: "
        issues = gop.issues

        puts
        puts "\e[92mPlan #{gop.plan.id} issues: [ " + issues.join(', ') + "]\e[39m"
        # gop.show_plan

        if issues.empty?

          puts "No issues. Starting plan.\e[39m"
          gop.recurse do |op|
            op.user_id = gop.user_id
            if op.status == "planning"
              op.status = op.leaf? ? "pending" : "waiting"
            end
            op.save
          end

        else

          puts "Issues: " + issues.join(', ') + " \e[39m"

        end

      end

      run

    end

  end

end
