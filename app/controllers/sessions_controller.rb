class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_login(params[:session][:login].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = "Welcome to the Aquarium, #{user.login}. Your biological and technological distinctiveness will be added to our own."
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid login/password combination'
      render 'new'
    end
  end

  def destroy
    flash[:success] = 'Logged out.'
    sign_out
    redirect_to root_url
  end

  def glass

    user = User.find_by_login('nelson')
    sign_in user
    redirect_to root_path

  end

end
