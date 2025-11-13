require "test_helper"

class StagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @stage = stages(:one)
  end

  test "should get index" do
    get stages_url
    assert_response :success
  end

  test "should get show" do
    get stage_url(@stage)
    assert_response :success
  end

  test "should get new when logged in" do
    log_in_as(@user)
    get new_stage_url
    assert_response :success
  end

  test "should create stage when logged in" do
    log_in_as(@user)
    assert_difference("Stage.count", 1) do
      post stages_url, params: { stage: { title: "New Stage", description: "Description", stage_guid: "12345678901" } }
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "should get edit when logged in as owner" do
    log_in_as(@user)
    get edit_stage_url(@stage)
    assert_response :success
  end

  test "should update stage when logged in as owner" do
    log_in_as(@user)
    patch stage_url(@stage), params: { stage: { title: "Updated Title", description: "Updated Description", stage_guid: @stage.stage_guid, locale: @stage.locale } }
    assert_response :redirect
  end

  test "should destroy stage when logged in as owner" do
    log_in_as(@user)
    assert_difference("Stage.count", -1) do
      delete stage_url(@stage)
    end
    assert_response :redirect
  end

  private
    def log_in_as(user)
      post login_path, params: { login: user.username, password: "password" }
    end
end
