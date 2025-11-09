require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post signup_path, params: { user: { username: "newuser", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to stages_path
  end

  test "should redirect to login when not logged in for edit" do
    get profile_path
    assert_redirected_to login_path
  end

  test "should get edit when logged in" do
    log_in_as(@user)
    get profile_path
    assert_response :success
  end

  test "should update profile without password change" do
    log_in_as(@user)
    patch profile_path, params: { user: { nickname: "Updated Nickname", email: "updated@example.com" } }
    assert_redirected_to profile_path
    @user.reload
    assert_equal "Updated Nickname", @user.nickname
    assert_equal "updated@example.com", @user.email
  end

  test "should update password with correct current password" do
    log_in_as(@user)
    patch profile_path, params: {
      user: {
        current_password: "password",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_redirected_to profile_path
    @user.reload
    assert @user.authenticate("newpassword123")
  end

  test "should not update password with incorrect current password" do
    log_in_as(@user)
    patch profile_path, params: {
      user: {
        current_password: "wrongpassword",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_response :unprocessable_entity
  end

  private
    def log_in_as(user)
      post login_path, params: { session: { username: user.username, password: "password" } }
    end
end
