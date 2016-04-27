class InvoicesController < ApplicationController

  before_filter :signed_in_user

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

    @data = (1..12).collect { |m| 
      { 
        month: m,
        year: year,
        date: DateTime.new(year,m),
        entries: Account.users_and_budgets(year, m,user)
      }
    }.reverse.reject { |d| d[:entries].length == 0 }

  end

  def show
    @invoice = Invoice.find(params[:id])
    @date = DateTime.new(@invoice.year,@invoice.month)
    @rows = @invoice.rows
    @tps = TaskPrototype.all
    @base = Account.total(@rows,false)
    @total = Account.total(@rows,true)
    @markup = @total - @base
  end

  def note

    if current_user.is_admin

      notes = [];
      params[:rows].each do |k,row|
        al = AccountLog.new({
          row1: row[:id],
          row2: nil,
          task_id: row[:task_id],
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
          task_id: transaction.task_id,
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
          task_id: row[:task_id],
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
