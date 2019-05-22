# frozen_string_literal: true

class JobsController < ApplicationController

  before_filter :signed_in_user

  def index

    @users = User.all - User.includes(memberships: :group)
                            .where(memberships: { group_id: Group.find_by_name('retired') })
    @groups = Group.includes(:memberships).all.reject { |g| g.memberships.length == 1 }

    respond_to do |format|
      format.html { render layout: 'aq2' }
    end

  end

  def joblist
    logger.info params
    render json: JobsDatatable.new(view_context)
  end

  def show

    begin
      @job = Job.find(params[:id])
    rescue StandardError
      redirect_to logs_path
      return
    end

    redirect_to krill_log_path(job: @job.id)

  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

  def upload
    redirect_to Upload.find(params[:id]).url
  end

  def report
    start = DateTime.parse(params[:date]).beginning_of_day
    render json: Job.includes(:user, job_associations: { operation: :operation_type })
                    .where('? < updated_at AND updated_at < ?', start - 1.day, start + 1.day)
                    .select { |job| job.pc == Job.COMPLETED && !job.job_associations.empty? }
                    .to_json(include: [:user, { job_associations: { include: { operation: { include: :operation_type } } } }])
  rescue Exception => e
    render json: { error: e.to_s }
  end

end
