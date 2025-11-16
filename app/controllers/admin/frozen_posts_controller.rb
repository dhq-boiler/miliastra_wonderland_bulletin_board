class Admin::FrozenPostsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @filter = params[:filter] || "all"

    # Stagesとコメントを取得
    stages = Stage.frozen.includes(:user).recent
    comments = MultiplayRecruitmentComment.frozen.includes(:user, :multiplay_recruitment).recent

    case @filter
    when "temporary"
      stages = stages.temporarily_frozen
      comments = comments.temporarily_frozen
    when "permanent"
      stages = stages.permanently_frozen
      comments = comments.permanently_frozen
    end

    # 凍結日時でソートするため、配列に結合
    @frozen_posts = (stages.to_a + comments.to_a).sort_by { |post| post.frozen_at }.reverse

    # 統計情報
    @stats = {
      total: Stage.frozen.count + MultiplayRecruitmentComment.frozen.count,
      temporary: Stage.temporarily_frozen.count + MultiplayRecruitmentComment.temporarily_frozen.count,
      permanent: Stage.permanently_frozen.count + MultiplayRecruitmentComment.permanently_frozen.count
    }
  end

  def unfreeze_stage
    stage = Stage.find(params[:id])
    stage.unfreeze!
    redirect_to admin_frozen_posts_path, notice: "ステージの凍結を解除しました。"
  end

  def unfreeze_comment
    comment = MultiplayRecruitmentComment.find(params[:id])
    comment.unfreeze!
    redirect_to admin_frozen_posts_path, notice: "コメントの凍結を解除しました。"
  end

  def permanent_freeze_stage
    stage = Stage.find(params[:id])
    stage.freeze_post!(type: :permanent, reason: params[:reason] || "管理者による永久凍結")
    redirect_to admin_frozen_posts_path, notice: "ステージを永久凍結しました。"
  end

  def permanent_freeze_comment
    comment = MultiplayRecruitmentComment.find(params[:id])
    comment.freeze_post!(type: :permanent, reason: params[:reason] || "管理者による永久凍結")
    redirect_to admin_frozen_posts_path, notice: "コメントを永久凍結しました。"
  end

  def destroy_stage
    stage = Stage.find(params[:id])
    stage.destroy
    redirect_to admin_frozen_posts_path, notice: "ステージを削除しました。"
  end

  def destroy_comment
    comment = MultiplayRecruitmentComment.find(params[:id])
    comment.destroy
    redirect_to admin_frozen_posts_path, notice: "コメントを削除しました。"
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "アクセス権限がありません。"
    end
  end
end
