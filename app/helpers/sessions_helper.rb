module SessionsHelper

  def login(user)
    session[:user_id] = user.id
  end

  # is stored in permanent session the user
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # return user who login current(be logged in)
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        login(user)
        @current_user = user
      end
    end
  end

  # redirect to remembering URL
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # save URL because try to access
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  # return true because user is logging
  def loggedin?
    !current_user.nil?
  end

  # forget sessions for parmanent
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # to logout current user
  def logout
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # return ture because given user when loggedin
  def current_user?(user)
    user == current_user
  end
end
