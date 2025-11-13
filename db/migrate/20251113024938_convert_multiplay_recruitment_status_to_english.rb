class ConvertMultiplayRecruitmentStatusToEnglish < ActiveRecord::Migration[8.1]
  def up
    # 日本語のステータスを英語に変換
    MultiplayRecruitment.where(status: "募集中").update_all(status: "recruiting")
    MultiplayRecruitment.where(status: "開催中").update_all(status: "in_progress")
    MultiplayRecruitment.where(status: "募集終了").update_all(status: "closed")
    MultiplayRecruitment.where(status: "終了").update_all(status: "finished")
  end

  def down
    # ロールバック時は英語から日本語に戻す
    MultiplayRecruitment.where(status: "recruiting").update_all(status: "募集中")
    MultiplayRecruitment.where(status: "in_progress").update_all(status: "開催中")
    MultiplayRecruitment.where(status: "closed").update_all(status: "募集終了")
    MultiplayRecruitment.where(status: "finished").update_all(status: "終了")
  end
end
