require "test_helper"

class StagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stages_index_url
    assert_response :success
  end

  test "should get show" do
    get stages_show_url
    assert_response :success
  end

  test "should get new" do
    get stages_new_url
    assert_response :success
  end

  test "should get create" do
    get stages_create_url
    assert_response :success
  end

  test "should get edit" do
    get stages_edit_url
    assert_response :success
  end

  test "should get update" do
    get stages_update_url
    assert_response :success
  end

  test "should get destroy" do
    get stages_destroy_url
    assert_response :success
  end
end
