class JsonController < ApplicationController

  before_filter :signed_in_user

  def index

    logger.info "IN INDEX: #{params}"

    begin

      result = Object.const_get(params[:model])
      result = result.find(params[:id]) if params[:id] 
      result = result.send(params[:method],*params[:arguments]) if params[:method]
      result = result.as_json(methods: params[:methods]) if ( params[:methods] )

      render json: result

    rescue Exception => e 

      logger.info e.to_s
      logger.info e.backtrace.to_s
      render json: { errors: e.to_s }, status: 422

    end

  end

  def current
    render json: current_user
  end

end
