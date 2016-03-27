module SessionsHelper

  def login(user)
    session[:user_id] = user.id
  end

  # return user who login current(be logged in)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # return true because user is logging
  def loggedin?
    !current_user.nil?
  end
end
