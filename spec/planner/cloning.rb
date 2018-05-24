require 'rails_helper'
require_relative 'gibson'
require_relative 'runner'

RSpec.describe 'Planner' do

  context 'plans' do

    it 'edits plans' do

      # build_workflow

      seq = OperationType.find_by_name 'Sequencing'

      goal = seq.operations.create status: 'planning', user_id: User.find_by_login('klavins').id
      goal.set_input('Plasmid', SampleType.find_by_name('Plasmid').samples.last)

      puts
      puts "\e[93mPlanning #{goal}\e[39m"

      planner = Planner.new OperationType.all
      planner.plan_tree goal

      puts
      puts "\e[93mMarking shortest plan\e[39m"
      planner.mark_shortest goal

      puts
      puts "\e[93mMarking unused operations\e[39m"
      planner.mark_unused goal

      puts
      puts "\e[93mPlan\e[39m"
      goal.reload
      goal.show_plan

      puts
      puts "\e[93mStatus: #{goal.issues.join(', ')}\e[39m"
      goal.recurse do |op|
        puts "op #{op.id} has inputs that need to be defined" if op.undetermined_inputs?
      end

      puts
      puts "\e[93mDefining inputs for Gibson and planning\e[39m"
      ops = goal.find 'Gibson Assembly'

      unless ops.empty?
        puts "Found Gibson Assembly: Op #{ops[0].id}"
        op = ops[0]
        op.set_input('Fragments', SampleType.find_by_name('Fragment').samples.sample(2))
        planner.plan_tree op
        planner.mark_shortest op
        planner.mark_unused op
      end

      puts
      puts "\e[93mNew Plan\e[39m"
      goal.reload
      goal.show_plan

      puts
      puts "\e[93mDefining inputs for E coli Transformation\e[39m"
      ops = goal.find 'Transform E coli'

      unless ops.empty?
        puts "Found Transform E coli: Op #{ops[0].id}"
        op = ops[0]
        op.set_input('Comp cell', Sample.find_by_name('DH5alpha'))
        planner.plan_tree op
        planner.mark_shortest op
        planner.mark_unused op
      end

      puts
      puts "\e[93mNew Plan\e[39m"
      goal.reload
      goal.show_plan
      issues = goal.issues

      puts
      puts "\e[92mPlan #{goal.plan.id} issues: [ " + issues.join(', ') + "]\e[39m"

      if issues.empty?

        puts "No issues. Starting plan.\e[39m"
        goal.recurse do |op|
          op.user_id = goal.user_id
          if op.status == 'planning'
            op.status = op.leaf? ? 'pending' : 'waiting'
          end
          op.save
        end

        run

      else

        puts "Can't run. Issues: " + issues.join(', ') + " \e[39m"

      end

    end

  end

end
