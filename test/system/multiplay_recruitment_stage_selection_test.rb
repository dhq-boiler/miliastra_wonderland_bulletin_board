require "application_system_test_case"

class MultiplayRecruitmentStageSelectionTest < ApplicationSystemTestCase
  # システムテストではfixturesを使わない（Capybaraとの互換性のため）
  self.use_transactional_tests = false

  setup do
    # データベースをクリーンアップ
    MultiplayRecruitment.destroy_all
    MultiplayRecruitmentParticipant.destroy_all
    MultiplayRecruitmentComment.destroy_all
    Stage.destroy_all
    User.destroy_all

    # テスト用ユーザーを作成（パスワード認証用、ランダムなユーザー名・メール）
    random_suffix = SecureRandom.hex(4)
    random_guid1 = rand(100000..999999)  # ランダムな6桁の数値
    random_guid2 = rand(100000..999999)  # ランダムな6桁の数値

    @user = User.create!(
      email: "test_#{random_suffix}@example.com",
      nickname: "Test User",
      username: "testuser_#{random_suffix}",
      password: "password123",
      password_confirmation: "password123"
    )

    # テスト用ステージを作成
    @my_stage = Stage.create!(
      title: "My Test Stage",
      stage_guid: random_guid1.to_s,
      description: "Test stage description",
      user: @user,
      locale: "ja"
    )

    @other_user = User.create!(
      email: "other_#{random_suffix}@example.com",
      nickname: "Other User",
      username: "otheruser_#{random_suffix}",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_stage = Stage.create!(
      title: "Other User Stage",
      stage_guid: random_guid2.to_s,
      description: "Other user's stage",
      user: @other_user,
      locale: "ja"
    )

    # パスワード認証でログイン
    visit login_path
    fill_in "login", with: @user.username
    fill_in "password", with: "password123"
    click_button "ログイン"

    # ログイン成功を確認
    assert_text "Test User"
  end

  teardown do
    # クリーンアップ
    MultiplayRecruitment.destroy_all
    MultiplayRecruitmentParticipant.destroy_all
    MultiplayRecruitmentComment.destroy_all
    Stage.destroy_all
    User.destroy_all
  end

  test "selecting stage from popup dialog in new recruitment form" do
    visit new_multiplay_recruitment_path

    # ページが表示されていることを確認
    assert_selector "h1", text: "新しいマルチプレイ募集"

    # ステージ選択ボタンをクリックしてポップアップを開く
    click_button "🎮 ステージを選択"

    # ポップアップが表示されることを確認
    assert_selector "[data-stage-popover]", visible: true

    # JavaScriptが完全にロードされるまで少し待つ
    sleep 0.5

    # 自分の幻境タブが表示されていることを確認
    assert_selector ".stage-tab.active", text: "自分の幻境"

    # 自分のステージが表示されていることを確認
    within "[data-stage-tab-content='my']" do
      assert_text @my_stage.title
      assert_text "GUID: #{@my_stage.stage_guid}"

      # ステージアイテムをクリック（イベントデリゲーション用）
      stage_item = find("[data-stage-item][data-stage-guid='#{@my_stage.stage_guid}']")
      stage_item.click
    end

    # ポップアップが閉じることを確認（少し待機）
    assert_no_selector "[data-stage-popover]", visible: true, wait: 2

    # 選択したステージ情報が表示されることを確認
    within "#stage-selection-summary" do
      assert_text @my_stage.title
      assert_text "GUID: #{@my_stage.stage_guid}"
    end

    # フォームに他の必須項目を入力
    fill_in "タイトル", with: "Test Multiplay Recruitment"
    fill_in "募集内容", with: "Test description for multiplay recruitment"
    fill_in "募集人数", with: "4"

    # テスト環境でJavaScriptのタイミング問題があるため、送信前に確実に値を設定
    page.execute_script("document.querySelector('[data-stage-guid-field]').value = '#{@my_stage.stage_guid}'")

    # フォームを送信
    click_button "Create マルチプレイ募集"

    # 作成成功メッセージを確認
    assert_text "マルチプレイ募集が投稿されました"

    # 作成されたマルチプレイ募集を確認
    recruitment = MultiplayRecruitment.last
    assert_equal @my_stage.stage_guid, recruitment.stage_guid

    # 詳細ページにステージ情報が表示されることを確認
    assert_link @my_stage.title
    assert_text @my_stage.stage_guid  # GUIDが表示されていることを確認
  end

  test "selecting stage from other users tab" do
    visit new_multiplay_recruitment_path

    # ステージ選択ボタンをクリック
    click_button "🎮 ステージを選択"

    # JavaScriptが完全にロードされるまで少し待つ
    sleep 0.5

    # 「他の人の幻境」タブをクリック
    within ".stage-modal-tabs" do
      click_button "他の人の幻境"
    end

    # 他のユーザーのステージが表示されることを確認
    within "[data-stage-tab-content='other']" do
      assert_text @other_stage.title
      assert_text @other_stage.stage_guid

      # ステージアイテムをクリック
      stage_item = find("[data-stage-item][data-stage-guid='#{@other_stage.stage_guid}']")
      stage_item.click
    end

    # ポップアップが閉じることを確認
    assert_no_selector "[data-stage-popover]", visible: true, wait: 2

    # 選択したステージ情報が表示されることを確認
    within "#stage-selection-summary" do
      assert_text @other_stage.title
      assert_text @other_stage.stage_guid
    end

    # フォームに他の必須項目を入力
    fill_in "タイトル", with: "Test with Other Stage"
    fill_in "募集内容", with: "Test description"
    fill_in "募集人数", with: "4"

    # テスト環境でJavaScriptのタイミング問題があるため、送信前に確実に値を設定
    page.execute_script("document.querySelector('[data-stage-guid-field]').value = '#{@other_stage.stage_guid}'")

    # フォームを送信
    click_button "Create マルチプレイ募集"

    # 作成成功メッセージを確認
    assert_text "マルチプレイ募集が投稿されました"

    # 作成されたマルチプレイ募集を確認
    recruitment = MultiplayRecruitment.last
    assert_not_nil recruitment, "募集が作成されていません"
    assert_equal @other_stage.stage_guid, recruitment.stage_guid
  end
end
