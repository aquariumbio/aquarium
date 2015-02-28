class Jobb < Job

  def attributes
    a = super
    a["backtrace"] = a["state"]
    a.delete "state"
    a
  end

end

class Userr < User

  def attributes
    a = super
    a.delete "password_digest"
    a.delete "remember_token"
    a.delete "key"
    a
  end

end

class ApiController < ApplicationController 

  def valid_user_and_key?

    @user = User.find_by_login(params[:login])
    if @user && @user.key == params[:key]
      return true
    else
      (@errors ||= []).push "Invalid user / key combination"
      return false
    end

  end

  def error
    render json: { result: "error", messages: @errors }
  end

  def ok data={}
    render json: ( { result: "ok" }.merge data )
  end

  def main

    if valid_user_and_key?

      if params[:run] && params[:run][:method]
        begin
          run params[:run][:method], params[:run][:args]
        rescue Exception => e
          logger.error e
          (@errors ||= []).push "Could not execute request"
          error
        end
      end

    else

      error

    end

  end

  def run method, args

    case method
      when "find"
        find args
      else
        ok warning: "No methods found"
    end

  end

  def find args

    models = { "item" => Item, "job" => Jobb, "sample" => Sample, "user" => Userr, 
               "task" => Task, "sampletype" => SampleType, "objecttype" => ObjectType }

    ok({ rows: models[args[:model]].where(args[:where]) })

  end

end

