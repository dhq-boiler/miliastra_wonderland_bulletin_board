module MultiplayRecruitmentsHelper
  def status_badge_class(status)
    case status
    when "募集中"
      "status-recruiting"
    when "募集終了"
      "status-closed"
    when "開催中"
      "status-ongoing"
    when "終了"
      "status-finished"
    else
      "status-default"
    end
  end
end

