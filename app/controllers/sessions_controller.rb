class SessionsController < ApplicationController

  def new
    render layout: "blank.html.erb"
  end

  def create
    user = User.find_by_login(params[:session][:login].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = "Welcome to the Aquarium, #{user.login}. Your biological and technological distinctiveness will be added to our own."
      redirect_back_or root_url
    else
      flash.now[:error] = 'Invalid login/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    render 'new', layout: "blank.html.erb"
  end

end
