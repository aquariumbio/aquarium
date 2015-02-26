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
      ok
    else
      error
    end

  end

end