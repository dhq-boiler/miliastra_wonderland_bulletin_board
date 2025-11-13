require "test_helper"

class SoftDeletableTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      username: "soft_delete_test_user",
      email: "soft_delete_test@example.com",
      password: "password123"
    )

    @stage = Stage.create!(
      user: @user,
      title: "Test Stage",
      description: "Test Description",
      stage_guid: "99999"
    )

    @recruitment = MultiplayRecruitment.create!(
      user: @user,
      title: "Test Recruitment",
      description: "Test Description",
      max_players: 4,
      status: MultiplayRecruitment::STATUSES[:recruiting]
    )

    @comment = MultiplayRecruitmentComment.create!(
      multiplay_recruitment: @recruitment,
      user: @user,
      content: "Test Comment"
    )
  end

  def teardown
    # テストデータをクリーンアップ（子から順に削除）
    [ @comment, @recruitment, @stage, @user ].compact.each do |record|
      next unless record.persisted?

      # 削除済みの場合は復元してから物理削除
      if record.deleted?
        record.restore
      end
      record.hard_destroy
    rescue ActiveRecord::RecordNotFound
      # すでに削除されている場合は無視
    end
  end

  test "user soft delete should set deleted_at" do
    @user.destroy
    assert @user.deleted?
    assert_not_nil @user.deleted_at
  end

  test "soft deleted user should not be found by default scope" do
    user_id = @user.id
    @user.destroy
    assert_nil User.find_by(id: user_id)
  end

  test "soft deleted user should be found with with_deleted scope" do
    user_id = @user.id
    @user.destroy
    assert_not_nil User.with_deleted.find_by(id: user_id)
  end

  test "soft deleted user can be restored" do
    user_id = @user.id
    @user.destroy

    restored_user = User.with_deleted.find(user_id)
    restored_user.restore

    assert_not restored_user.deleted?
    assert_nil restored_user.deleted_at
    assert_not_nil User.find_by(id: user_id)
  end

  test "stage soft delete works correctly" do
    stage_id = @stage.id
    @stage.destroy

    assert @stage.deleted?
    assert_nil Stage.find_by(id: stage_id)
    assert_not_nil Stage.with_deleted.find_by(id: stage_id)
  end

  test "multiplay_recruitment soft delete works correctly" do
    recruitment_id = @recruitment.id
    @recruitment.destroy

    assert @recruitment.deleted?
    assert_nil MultiplayRecruitment.find_by(id: recruitment_id)
    assert_not_nil MultiplayRecruitment.with_deleted.find_by(id: recruitment_id)
  end

  test "multiplay_recruitment_comment soft delete works correctly" do
    comment_id = @comment.id
    @comment.destroy

    assert @comment.deleted?
    assert_nil MultiplayRecruitmentComment.find_by(id: comment_id)
    assert_not_nil MultiplayRecruitmentComment.with_deleted.find_by(id: comment_id)
  end

  test "only_deleted scope returns only deleted records" do
    # 新しいユーザーを作成（削除されていない）
    active_user = User.create!(
      username: "active_user",
      email: "active@example.com",
      password: "password123"
    )

    # @userを削除
    @user.destroy

    deleted_users = User.only_deleted.all
    active_users = User.all

    assert_includes deleted_users.map(&:id), @user.id
    assert_not_includes active_users.map(&:id), @user.id
    assert_includes active_users.map(&:id), active_user.id

    # クリーンアップ
    active_user.destroy!
  end

  test "destroy! performs hard delete" do
    user_id = @user.id

    # 外部キー制約のため、先に子レコードを削除
    @comment.destroy!
    @recruitment.destroy!
    @stage.destroy!
    @user.destroy!

    # データベースから直接確認（unscopedを使用）
    assert_nil User.unscoped.find_by(id: user_id), "User should be physically deleted from database"

    # teardownでエラーが出ないようにnilに設定
    @comment = nil
    @recruitment = nil
    @stage = nil
    @user = nil
  end

  test "soft_delete_all deletes multiple records" do
    # 追加のユーザーを作成
    users_to_delete = []
    3.times do |i|
      users_to_delete << User.create!(
        username: "bulk_delete_#{i}",
        email: "bulk_delete_#{i}@example.com",
        password: "password123"
      )
    end

    user_ids = users_to_delete.map(&:id)
    User.where(id: user_ids).soft_delete_all

    # 削除されたことを確認
    assert_equal 0, User.where(id: user_ids).count
    assert_equal 3, User.with_deleted.where(id: user_ids).count

    # クリーンアップ
    User.with_deleted.where(id: user_ids).each(&:destroy!)
  end
end
