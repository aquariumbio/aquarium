class LogsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index

    cookies[:logs_search_string] ||= current_user.login

    respond_to do |format|
      format.html { render layout: 'aq2' }
      format.json { render json: LogsDatatable.new(view_context) }
    end

  end

  def show
    @log = Log.find(params[:id])

    respond_to do |format|
      format.html { render layout: 'aq2' }
      format.json { render json: @log }
    end
  end

end
