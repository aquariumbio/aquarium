# frozen_string_literal: true

class AccountsController < ApplicationController

  before_filter :signed_in_user

  def index

    @user = User.find_by_id(params[:uid]) || current_user

    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    @start_date = DateTime.new(@year.to_i, @month.to_i)
    @end_date = @start_date.next_month
    @next_month = @start_date.next_month
    @prev_month = @start_date.prev_month

    if @user == current_user || current_user.is_admin

      @all_rows = Account.where(
        'user_id = ?',
        @user.id
      )

      @current_rows = Account.where(
        'user_id = ? and ? <= created_at and created_at < ?',
        @user.id,
        @start_date,
        @end_date
      )

      @prev_rows = Account.where(
        'user_id = ? and created_at < ?',
        @user.id,
        @start_date
      )

      @balances = @all_rows
                  .collect(&:budget_id)
                  .uniq
                  .collect do |bid|
        {
          budget: Budget.find(bid),
          prev: @prev_rows
            .select { |r| r.budget_id == bid }
            .collect { |r| r.transaction_type == 'credit' ? r.amount : - r.amount }
            .inject(0) { |sum, x| sum + x },
          current: (@current_rows + @prev_rows)
            .select { |r| r.budget_id == bid }
            .collect { |r| r.transaction_type == 'credit' ? r.amount : - r.amount }
            .inject(0) { |sum, x| sum + x },
          debits: @current_rows
            .select { |r| r.budget_id == bid && r.transaction_type == 'debit' }
            .collect { |r| -r.amount }
            .inject(0) { |sum, x| sum + x },
          credits: @current_rows
            .select { |r| r.budget_id == bid && r.transaction_type == 'credit' }
            .collect(&:amount)
            .inject(0) { |sum, x| sum + x }
        }
      end

    else

      @unauthorized = true
      @rows = []

    end

  end

  def deposit

    if current_user.is_admin

      if params[:amount] != '' && params[:amount].to_f > 0

        user = User.find(params[:uid])
        budget = Budget.find(params[:bid])
        description = "#{current_user.name} deposited $#{params[:amount]} associated budget #{budget.name}."

        row = Account.new(
          user_id: user.id,
          category: nil,
          amount: params[:amount].to_f,
          budget_id: budget.id,
          description: description,
          task_id: -1,
          job_id: -1,
          transaction_type: 'credit'
        )

        row.save

        flash[:notice] = description

      else
        flash[:notice] = "Could not deposit amount '#{params[:amount]}'."
      end

      redirect_to :accounts

    else

      flash[:error] = 'Not admin'
      redirect_to :accounts

    end

  end

end
