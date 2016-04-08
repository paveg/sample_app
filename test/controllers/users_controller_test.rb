require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should redirect index when not logged in' do
    get :index
    assert_redirected_to login_url
  end

  test 'should redirect edit when not loggedin' do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not loggedin' do
    patch :update, id: @user, user: {
      name:  @user.name,
      email: @user.email
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect edit when loggedin as wrong user' do
    login_as(@other_user)
    get :edit, id: @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when loggedin as wrong user' do
    login_as(@other_user)
    patch :update, id: @user, user: {
      name:  @user.name,
      email: @user.email
    }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect destroy when not loggedin' do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test 'should redirect destroy when loggedin as a non-admin' do
    login_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end
end
