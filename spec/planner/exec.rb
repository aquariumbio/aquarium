require "rails_helper"
require_relative "workflow"
require_relative "gibson"

RSpec.describe "Planner" do

  context "plans" do

    it "executes plans" do

      build_workflow

      # do some planning
      (1..6).each do |i|

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

      while Operation.where(status: "pending").count > 0

        puts
        puts "\e[93mScheduling and running operations!\e[39m"   
        puts "\e[93m----------------------------------------------------------------------------------\e[39m"                

        OperationType.all.each do |ot|

          if ot.pending.count + ot.waiting.count > 0
            puts "\e[4m#{ot.name}: #{ot.pending.count} pending, #{ot.waiting.count} waiting, and #{ot.done.count} done\e[0m"
          end

          if ot.pending.count > 0

            ops = ot.pending
            job = ot.schedule(ops, User.find_by_login('klavins'), Group.find_by_name('technicians'))
            puts "  Scheduled job #{job.id}"

            job.user_id = User.find_by_login('klavins').id
            job.save

            puts "  Starting job #{job.id}"
            manager = Krill::Manager.new job.id, true, "master", "master"
            manager.run

            job.reload

            if job.error?
              puts "Job #{job.id} failed: #{job.error_message}"
              puts job.error_backtrace.join("\n")            
              raise "Job #{job.id} failed"
            else
              ops.each do |op|
                op.status = "done"
                op.save
                op.successors.each do |suc|
                  puts "Considering operation #{suc.id} (#{suc.name})"
                  if suc.status == "waiting" && suc.ready?
                    puts "  Changing operation #{suc.id}'s status to pending!"
                    suc.status = "pending"
                    suc.save
                    suc.reload
                    puts "  #{suc.id}'s status is now #{suc.status}."                      
                    puts "ERROR UPDATING STATUS" unless suc.errors.empty?
                  end
                end
              end
            end

          end          

        end

        puts "At end of round there are #{Operation.where(status: 'pending').count} pending, #{Operation.where(status: 'waiting').count} waiting, and #{Operation.where(status: 'done').count} done operations"

      end 

    end

  end

end
