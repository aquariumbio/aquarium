# typed: false
# frozen_string_literal: true

class DevOnlyController < ApplicationController

  def index

    assignment = JobAssignmentLog.new
    assignment.job_id = 3
    assignment.assigned_by = 13
    assignment.assigned_to = 14
    assignment.save

    assignment = JobAssignmentLog.new
    assignment.job_id = 4
    assignment.assigned_by = 15
    assignment.assigned_to = 16
    assignment.save

    @assignment = JobAssignmentLog.get_assignment(3)

    render :layout => false

  end

end
