class SessionsController < ApplicationController

  def new
    render layout: 'blank.html.erb'
  end

  def create

    user = User.find_by(login: params[:session][:login].downcase)

    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = "Welcome to the Aquarium, #{user.login}. Your biological and technological distinctiveness will be added to our own."
      # redirect_to root_url

      respond_to do |format|
        format.html { redirect_to root_url } # index.html.erb
        format.json { render json: { message: 'Log in successful' } }
      end

    else
      flash.now[:error] = 'Invalid login/password combination'

      respond_to do |format|
        format.html { render 'new', layout: 'blank.html.erb' } # index.html.erb
        format.json { render json: { message: 'Login failed' }, status: :unprocessable_entity }
      end

    end
  end

  def destroy
    sign_out
    render 'new', layout: 'blank.html.erb'
  end

end
