# frozen_string_literal: true

class InvoicesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end
 
  def note

    if current_user.is_admin

      notes = []
      params[:rows].each do |row|
        al = AccountLog.new(
          row1: row[:id],
          row2: nil,
          user_id: current_user.id,
          note: params[:note]
        )
        al.save
        notes << al
      end
      render json: { notes: notes }

    else

      render json: { error: 'Only users in the admin group can make notes to transactions.' }

    end

  end

  def change_budget

    budget = Budget.find(params[:budget_id])
    rows = []

    if params[:rows]
      params[:rows].each do |val|
        logger.info val[:id]
        row = Account.find(val[:id])
        row.budget_id = budget.id
        row.save
        logger.info "Errors: #{row.errors.any?}"
        rows << row
      end
    end

    render json: { budget: budget, rows: rows }

  end

  def change_status

    invoice = Invoice.find(params[:id])
    invoice.status = params[:status]
    invoice.save

    if invoice.errors.empty?
      render json: { invoice: invoice }
    else
      render json: { error: invoice.errors.full_messages.join(', ') }
    end

  end

  def credit
    if current_user.is_admin
      notes = []
      rows = []

      errors = nil
      params[:rows].each do |row|
        credit = create_credit(transaction: Account.find(row[:id]),
                               percentage: params[:percent].to_f)
        credit.save
        logger.info credit.errors.full_messages
        unless credit.errors.empty?
          errors = credit.errors
          break
        end

        al = AccountLog.new(
          row1: row[:id],
          row2: credit.id,
          user_id: current_user.id,
          note: "#{params[:percent]}% credit. " + params[:note]
        )
        al.save
        notes << al
        rows << credit
      end

      response = if errors.present?
                   { error: errors.full_messages.join(', ') }
                 else
                   { notes: notes, rows: rows.as_json(include: :operation) }
                 end
    else
      response = { error: 'Only users in the admin group can make notes to transactions.' }
    end

    render json: response
  end

  def budgets_used
    budget_ids = Account
      .where("year(created_at) = #{params[:year]} and month(created_at) = #{params[:month]}")
      .select(:budget_id)
      .collect { |a| a.budget_id }
      .uniq
    render json: budget_ids
  end  

  private

  def create_credit(transaction:, percentage:)
    Account.new(
      user_id: transaction.user_id,
      budget_id: transaction.budget_id,
      labor_rate: 0.0,
      markup_rate: 0.0,
      transaction_type: 'credit',
      amount: (0.01 * percentage) * transaction.amount * (1.0 + transaction.markup_rate),
      operation_id: transaction.operation_id,
      category: 'credit',
      description: 'Credit due to a lab error or similar issue: credit'
    )
  end

end
