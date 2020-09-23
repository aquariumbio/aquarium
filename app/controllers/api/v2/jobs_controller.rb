class Api::V2::JobsController < ApplicationController
  include ApiHelper

  def job
    # GET JOB
    id = params[:id].to_i
    job = Job.find(id) rescue nil
    render json: api_error( { "job_id" => ["invalid job"] } ) and return if !job

    render json: api_ok(job)
  end

  def assignment
    # GET JOB
    id = params[:id].to_i
    job = Job.find(id) rescue nil
    render json: api_error( { "job_id" => ["invalid job"] } ) and return if !job

    result = job.job_assignment

    render json: api_ok(result)
  end

  def assign
    @id = params[:id].to_i
    job = Job.find(@id) rescue nil
    render json: api_error( { "job_id" => ["invalid job"] } ) and return if !job

    @by = current_user.id rescue nil
    @to = params[:to].to_i

    api_ok(job_post_assignment)
    return
  end

  def unassign
    @id = params[:id].to_i
    job = Job.find(@id) rescue nil
    render json: api_error( { "job_id" => ["invalid job"] } ) and return if !job

    @by = current_user.id rescue nil
    @to = nil

    api_ok(job_post_assignment)
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
      result = api_ok(jal)
    else
      result = api_error(jal.errors)
    end

    render json: result
  end

end
