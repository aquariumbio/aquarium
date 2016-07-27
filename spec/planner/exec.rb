require "rails_helper"
require_relative "workflow"
require_relative "gibson"

RSpec.describe "Planner" do

  context "plans" do

    it "executes plans" do

      build_workflow

      # do some planning
      (1..4).each do 

        gop = plan_gibson 2
        puts
        print "\e[93mPlan: "
        issues = gop.issues

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

      puts
      puts "\e[93mStatus of Operations\e[39m"

      OperationType.all.each do |ot|

        puts "#{ot.name}: #{ot.pending.count} pending and #{ot.waiting.count} waiting"

        if ot.pending.count > 0

          job = ot.schedule(ot.pending, User.find_by_login('klavins'), Group.find_by_name('technicians'))
          puts "  Scheduled job #{job.id}"

          job.user_id = User.find_by_login('klavins').id
          job.save

          puts "  Starting job #{job.inspect}"
          manager = Krill::Manager.new job.id, true, "master", "master"

          begin
            status = manager.run
          rescue Exception => e
            puts "Error running manager"
          else
            puts "Manager returned #{status}!"
          end

          job.reload
          if job.error?
            puts "Job #{job.id} failed: #{job.error_message}"
            puts job.error_backtrace.join("\n")            
            raise "Job #{job.id} failed"
          end

        end

      end

    end

  end

end
