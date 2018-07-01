

class StaticPagesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def leader_board assoc, extra=nil, num=3

    assocs = assoc + "s"
    assocs_sym = assocs.to_sym

    lb = User.joins(assocs_sym) 
             .where("#{assocs}.created_at > ?", Date.today - num.month)

    lb = lb.where(extra) if extra
    
    lb = lb.select("users.*, COUNT(#{assocs}.id) count_accessor") 
           .group('users.id') 
           .collect { |u| { user: u, assocs_sym => u.count_accessor } } 
           .sort { |a,b| a[assocs_sym] <=> b[assocs_sym] } 
           .reverse

    compute_widths lb, assocs_sym

  end

  def compute_widths board, sym

    if board.length > 0

      n = [9, board.length].min
      w = board[0][sym] - board[n][sym]
      w = 0.01 if w == 0 
      m = 90.0 / w
      b = (10 * (board[0][sym] - 10 * board[n][sym] ) ) / w
      board.each do |row|
        row[:width] = m * row[sym] + b
      end

    end

  end

  def home

    @announcements = Announcement.find(:all, order: 'id desc', limit: 5)

    @sample_board = leader_board "sample"
    @job_board = leader_board "job"
    @plan_board = leader_board "plan", "plans.budget_id IS NOT NULL"   

    done = Plan.joins(:plan_associations) \
      .joins(plan_associations: :operation) \
      .includes(:user) \
      .where("plans.created_at > ? AND operations.status = 'done'", Date.today - 3.month) \
      .select("plans.*, COUNT(plan_associations.id) op_count") \
      .group('plans.id') \
      .collect { |p| { plan: p, ops: p.op_count, user: p.user } } \
      .sort { |a,b| a[:ops] <=> b[:ops] } \
      .reverse
      .first(20)

    all = Plan.joins(:plan_associations) \
      .joins(plan_associations: :operation) \
      .includes(:user) \
      .where("plans.created_at > ?", Date.today - 3.month) \
      .select("plans.*, COUNT(plan_associations.id) op_count") \
      .group('plans.id') \
      .collect { |p| { plan: p, ops: p.op_count, user: p.user } } \
      .sort { |a,b| a[:ops] <=> b[:ops] } \
      .reverse

    @biggest_plans = done[0..20].select { |x| all.find { |y| x[:plan].id == y[:plan].id }[:ops] == x[:ops] }

    compute_widths @biggest_plans, :ops

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

  def template
    respond_to do |format|
      format.html { render layout: 'aq2' }
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
    op = dp.operations.create status: "pending", user_id: current_user.id, x: 100, y: 100, parent_id: 0
    op.associate_plan plan
    job, operations = dp.schedule([op], current_user, Group.find_by_name(current_user.login))

    redirect_to("/krill/start?job=#{job.id}")

  end

end
