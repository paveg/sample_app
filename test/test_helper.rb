ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # return true for test user is logging
  def is_loggedin?
    !session[:user_id].nil?
  end

  # login by test_user
  def login_as(user, options = {})
    password    = options[:password] || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: {
        email:       user.email,
        password:    password,
        remember_me: remember_me
      }
    else
      session[:user_id] = user.id
    end
  end

  private

  # return if integration test
  def integration_test?
    defined?(post_via_redirect)
  end
end
