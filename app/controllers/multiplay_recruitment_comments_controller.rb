class MultiplayRecruitmentCommentsController < ApplicationController
  before_action :require_login, only: [ :create, :destroy ]
  before_action :set_multiplay_recruitment
  before_action :set_comment, only: [ :destroy ]
  before_action :authorize_user_or_admin, only: [ :destroy ]

  def create
    @comment = @multiplay_recruitment.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @multiplay_recruitment, notice: t("comments.create.success")
    else
      redirect_to @multiplay_recruitment, alert: t("comments.create.failure", errors: @comment.errors.full_messages.join(", "))
    end
  end

  def destroy
    @comment.destroy
    redirect_to @multiplay_recruitment, notice: t("comments.destroy.success")
  end

  private
    def set_multiplay_recruitment
      @multiplay_recruitment = MultiplayRecruitment.find(params[:multiplay_recruitment_id])
    end

    def set_comment
      @comment = @multiplay_recruitment.comments.find(params[:id])
    end

    def authorize_user_or_admin
      unless @comment.user == current_user || current_user.admin?
        redirect_to @multiplay_recruitment, alert: t("comments.errors.not_authorized_to_delete")
      end
    end

    def comment_params
      params.require(:multiplay_recruitment_comment).permit(:content, images: [])
    end
end
