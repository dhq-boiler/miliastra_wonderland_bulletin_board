module MultiplayRecruitmentCommentsHelper
  def comment_author?(comment)
    logged_in? && current_user == comment.user
  end

  def can_delete_comment?(comment)
    logged_in? && (current_user == comment.user || current_user.admin?)
  end
end
