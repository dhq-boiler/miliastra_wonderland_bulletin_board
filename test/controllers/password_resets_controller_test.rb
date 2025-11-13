require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_password_reset_url
    assert_response :success
  end

  test "should post create" do
    post password_resets_url, params: { email: @user.email }
    assert_response :redirect
  end

  test "should get edit with valid token" do
    @user.generate_password_reset_token
    get edit_password_reset_url(@user.reset_password_token)
    assert_response :success
  end

  test "should patch update with valid token" do
    @user.generate_password_reset_token
    patch password_reset_url(@user.reset_password_token), params: {
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_response :redirect
  end
end
