class JsonController < ApplicationController

  before_filter :signed_in_user

  def method_ok m

    if m

      if [ "all", "where", "find", "find_by_name", "new" ].member? m
        return true
      else
        raise "Illeagal method #{m} requested from front end."
      end
    else
      false
    end

  end

  def index

    begin

      result = Object.const_get(params[:model])
      result = result.find(params[:id]) if params[:id] 
      result = result.send(params[:method],*params[:arguments]) if method_ok(params[:method])
      result = result.as_json(methods: params[:methods]) if ( params[:methods] )

      render json: result

    rescue Exception => e 

      render json: { errors: e.to_s }, status: 422

    end

  end

  def sid str
    str ? str.split(':')[0] : 0
  end

  def items # ( sid, oid )

    begin

      sample = Sample.find_by_id(params[:sid])
      ot = ObjectType.find_by_id(params[:oid])

      if sample && ot

        if ot.handler == 'collection'
          render json: []
        else
          render json: sample.items.reject { |i| i.deleted? || i.object_type_id != ot.id }
        end

      elsif sample && !ot

        render json: []

      else

        render json: ot.items.reject { |i| i.deleted? }

      end  

    rescue Exception => e

      render json: { errors: "Could not find sample: #{e.to_s}" }, status: 422

    end

  end

  def current
    render json: current_user
  end

end
