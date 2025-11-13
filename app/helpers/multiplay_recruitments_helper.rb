module MultiplayRecruitmentsHelper
  def status_badge_class(status)
    case status
    when "recruiting"
      "status-recruiting"
    when "closed"
      "status-closed"
    when "in_progress"
      "status-ongoing"
    when "finished"
      "status-finished"
    else
      "status-default"
    end
  end

  # ステータスの表示用テキストを取得
  def status_text(status)
    key = MultiplayRecruitment::STATUSES.key(status)
    key ? t("app.multiplay.status.#{key}") : status
  end
end
