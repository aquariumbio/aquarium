# frozen_string_literal: true

class StaticPagesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def home
    @announcements = Announcement.find(:all, order: 'id desc', limit: 5)
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def test
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def dismiss
    cookies[:latest_announcement] = Announcement.last.id
    redirect_to root_path
  end

  def inventory_stats; end

  def inventory_critical; end

  def template
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def analytics
    @jobs = Job.where('created_at >= :date', date: Time.now.weeks_ago(0.5))
  end

  def location

    if params[:name] && params[:name] != 'undefined'
      cookies.permanent[:location] = params[:name]
    elsif params[:name] && params[:name] == 'undefined'
      cookies.delete :location
    end

    @current_location = if cookies[:location]
                          cookies[:location]
                        else
                          'undefined'
                        end

  end

  def direct_purchase

    dp = OperationType.find_by_name('Direct Purchase')

    unless dp
      flash[:error] = 'No direct purchase protocol found. Contact the lab manager.'
      redirect_to '/'
    end

    budgets = current_user.budgets

    if budgets.empty?
      flash[:error] = "No budgets for user #{current_user.name} found. Contact the lab manager."
      redirect_to '/'
    end

    plan = Plan.new(name: 'Direct Purchase by ' + current_user.name, budget_id: budgets[0].id)
    plan.save
    op = dp.operations.create status: 'pending', user_id: current_user.id, x: 100, y: 100, parent_id: -1
    op.associate_plan plan
    job, operations = dp.schedule([op], current_user, Group.find_by_name(current_user.login))

    redirect_to("/krill/start?job=#{job.id}")

  end

end
