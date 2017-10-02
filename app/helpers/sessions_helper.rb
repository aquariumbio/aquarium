module SessionsHelper

  def remember_token_symbol
    "remember_token_#{Bioturk::Application.environment_name}".to_sym
  end

  def sign_in(user)
    cookies.permanent[remember_token_symbol] = user.remember_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    rts = cookies[remember_token_symbol] ?  cookies[remember_token_symbol] : cookies["remember_token"] 
    @current_user ||= User.find_by_remember_token(rts)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in? 
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def up_to_date_user
    unless current_user.up_to_date
      redirect_to current_user
    end
  end

  def sign_out
    self.current_user = nil
    cookies.delete(remember_token_symbol)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

end
