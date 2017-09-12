class InvoicesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user  

  def index

    if !params[:year]
      year = Date.today.year
    else
      year = params[:year].to_i
    end

    if params[:all] && current_user.is_admin
      user = nil
    else
      user = current_user
    end

    @monthly_invoices = (1..12).collect { |m|
      { 
        month: m,
        year: year,
        date: DateTime.new(year,m),
        entries: Account.users_and_budgets(year, m, user)
      }
    }.reverse.reject { |d| d[:entries].length == 0 }

    respond_to do |format|
      format.html { render layout: 'aq2' }
    end   

  end

  def show
    @invoice = Invoice.find(params[:id])
    @date = DateTime.new(@invoice.year,@invoice.month)
    @rows = @invoice.rows
    @operation_types = OperationType.all
    @base = Account.total(@rows,false)
    @base_labor = Account.total(@rows.select { |row| row.category == "labor" }, false)
    @base_materials = Account.total(@rows.select { |row| row.category == "materials"}, false)
    @total = Account.total(@rows,true)
    @markup = @total - @base
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end       
  end

  def note

    if current_user.is_admin

      notes = [];
      params[:rows].each do |k,row|
        al = AccountLog.new({
          row1: row[:id],
          row2: nil,
          user_id: current_user.id,
          note: params[:note]
        })
        al.save
        notes << al
      end
      render json: { notes: notes }

    else 

      render json: { error: "Only users in the admin group can make notes to transactions." }      

    end

  end

  def change_budget

    task = Task.find(params[:task_id])
    budget = Budget.find(params[:budget_id])
    rows = []

    if params[:rows]
      params[:rows].each do |index,val|
        logger.info val[:id]
        row = Account.find(val[:id])
        row.budget_id = budget.id
        row.save
        rows << row
      end
    end

    task.budget_id = params[:budget_id]
    task.save

    if task.errors.empty?
      render json: { task: task, budget: budget, rows: rows }
    else
      render json: { error: task.errors.full_messages.join(', ') }
    end

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

      notes = [];
      rows = [];

      params[:rows].each do |k,row|

        transaction = Account.find(row[:id])

        credit = Account.new({
          user_id: transaction.user_id,
          budget_id: transaction.budget_id,
          labor_rate: 0.0,
          markup_rate: 0.0,
          transaction_type: "credit",
          amount: (0.01*params[:percent].to_f)*transaction.amount*(1.0+transaction.markup_rate),
          operation_id: transaction.operation_id,
          category: "credit",
          description: "Credit due to a BIOFAB error or similar issue: credit"
        })

        credit.save
        logger.info credit.errors.full_messages

        unless credit.errors.empty?
          render json: { error: credit.errors.full_messages.join(', ') }
          return
        end

        al = AccountLog.new({
          row1: row[:id],
          row2: credit.id,
          user_id: current_user.id,
          note: "#{params[:percent]}% credit. " + params[:note]
        })

        al.save
        notes << al
        rows << credit

      end

      render json: { notes: notes, rows: rows }

    else 

      render json: { error: "Only users in the admin group can make notes to transactions." }  

    end

  end

end 
