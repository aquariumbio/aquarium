require 'rails_helper'
require_relative 'gibson'

RSpec.describe 'Planner' do

  context 'plans' do

    it 'makes plans' do

      # build_workflow

      gop = plan_gibson 4

      puts
      print "\e[93mPlan: "

      issues = gop.issues
      if issues.empty?
        puts "No issues. \e[39m"
      else
        puts 'Issues: ' + issues.join(', ') + " \e[39m"
      end

      gop.show_plan

      puts gop.serialize

      plan = gop.plans.first
      puts "plan = #{plan.inspect}, ops = #{plan.operations.collect(&:id)}"

    end

  end

end
