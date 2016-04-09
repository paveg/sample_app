require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {
        name:                  '',
        email:                 'user@invalid',
        password:              'foo',
        password_confirmation: 'bar'
      }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: {
        name:                  'Example User',
        email:                 'user@example.com',
        password:              'password',
        password_confirmation: 'password'
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # login by non activate status
    login_as(user)
    assert_not is_loggedin?
    # case of activate token is invalid
    get edit_account_activation_path("invalid token")
    assert_not is_loggedin?
    # case of token is true but mailaddress is invalid
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_loggedin?
    # activate token is true
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_loggedin?
  end
end
