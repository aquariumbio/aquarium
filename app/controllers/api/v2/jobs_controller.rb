class Api::V2::JobsController < ApplicationController

  def job
    # GET JOB
    id = params[:id].to_i
    job = Job.find(id) rescue nil
    render json: { "error" => "invalid job" } and return if !job

    render json: job
  end

  def assignment
    # GET JOB
    id = params[:id].to_i
    job = Job.find(id) rescue nil
    render json: { "error" => "invalid job" } and return if !job

    result = job.job_assignment

    render json: result
  end

  def assign
    @id = params[:id].to_i
    job = Job.find(@id) rescue nil
    render json: { "status" => "invalid job" } and return if !job

    @by = current_user.id
    @to = params[:to].to_i

    job_post_assignment
    return
  end

  def unassign
    @id = params[:id].to_i
    job = Job.find(@id) rescue nil
    render json: { "status" => "invalid job" } and return if !job

    @by = current_user.id
    @to = nil

    job_post_assignment
    return
  end

private

  def job_post_assignment
    jal = JobAssignmentLog.new
    jal.job_id = @id
    jal.assigned_by = @by
    jal.assigned_to = @to

    jal.save!

    if jal.id
      result = jal
    else
      result = jal.errors
    end

    render json: result
  end

end
