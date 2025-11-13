require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post login_url, params: { login: @user.username, password: "password" }
    assert_response :redirect
    assert session[:user_id].present?
  end

  test "should not create session with invalid credentials" do
    post login_url, params: { login: @user.username, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "should destroy session" do
    post login_url, params: { login: @user.username, password: "password" }
    delete logout_url
    assert_response :redirect
    assert_nil session[:user_id]
  end
end
