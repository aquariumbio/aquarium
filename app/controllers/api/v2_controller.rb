class Api::V2Controller < ApplicationController

  def job
    @id = params[:id].to_i
    job = Job.find(@id) rescue nil

    if @id==0
      @result = { "return" => "jobs" }
      render json: @result and return
    elsif !job
      render json: { "status" => "invalid job" } and return
    end

    option = params[:option]
    case option
    when 'assignments'
      job_assignments
      return
    end

    @result = { "return" => "job #{@id}" }

    render json: @result
  end

  def job_post
    @id = params[:id].to_i
    job = Job.find(@id) rescue nil
    render json: { "status" => "invalid job" } and return if !job

    option = params[:option]
    case option
    when 'assignment'
      job_post_assignment
      return
    end

    @result = { "update" => "job #{@id}" }

    render json: @result
  end

  def user
    @id = params[:id].to_i
    user = User.find(@id) rescue nil

    if @id==0
      @result = { "return" => "users" }
      render json: @result and return
    elsif !user
      render json: { "status" => "invalid user" } and return
    end

    option = params[:option]
    case option
    when 'assignments'
      user_assignments
      return
    end

    @result = { "return" => "user #{@id}" }

    render json: @result
  end

  def group
    @id = params[:id].to_i
    group = Group.find(@id) rescue nil

    if @id==0
      @result = { "return" => "groups" }
      render json: @result and return
    elsif !group
      render json: { "status" => "invalid group" } and return
    end

    option = params[:option]
    case option
    when 'assignments'
      group_assignments
      return
    end

    @result = { "return" => "group #{@id}" }

    render json: @result
  end

private

  def job_assignments
    @result = { "return" => "job #{@id}", "data" => "assignments" }

    render json: @result
  end

  def job_post_assignment
    @result = { "create" => "job #{@id}", "data" => "assignments" }

    render json: @result
  end

  def user_assignments
    @result = { "return" => "user #{@id}", "data" => "job assignments" }

    render json: @result
  end

  def group_assignments
    @result = { "return" => "group #{@id}", "data" => "job assignments" }

    render json: @result
  end

end
