class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  # check user loggedin?
  def loggedin_user
    unless loggedin?
      store_location
      flash[:danger] = 'Please login.'
      redirect_to login_url
    end
  end
end
