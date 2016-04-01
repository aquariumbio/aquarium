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
  end

end