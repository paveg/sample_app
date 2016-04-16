require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'password resets' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # email address is invalid
    post password_resets_path, password_reset: { email: '' }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # email address is valid
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # password resetting form
    user = assigns(:user)
    # invalid email address
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url
    # invalid user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # email address is valid, token is invalid
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # email address and token are valid
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
    # invalid password and confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user:  {
            password:              'foobaz',
            password_confirmation: 'barquux'
          }
    assert_select 'div#error_explanation'
    # password is empty
    patch password_reset_path(user.reset_token),
          email: user.email,
          user:  {
            password:              '',
            password_confirmation: ''
          }
    assert_select 'div#error_explanation'
    # valid password and confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user:  {
            password:              'foobaz',
            password_confirmation: 'foobaz'
          }
    assert is_loggedin?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test 'expired token' do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          email: @user.email,
          user:  { password:              'foobar',
                   password_confirmation: 'foobar' }
    assert_response :redirect
    follow_redirect!
    assert_match /Password reset has expired\./i, response.body
  end
end
