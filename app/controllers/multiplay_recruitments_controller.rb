class MultiplayRecruitmentsController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_multiplay_recruitment, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update ]
  before_action :authorize_user_or_admin, only: [ :destroy ]

  def index
    base_query = MultiplayRecruitment.includes(:user).left_joins(:comments).group(:id).select("multiplay_recruitments.*, COUNT(multiplay_recruitment_comments.id) as comments_count")

    @active_recruitments = base_query.where(status: [ MultiplayRecruitment::STATUSES[:recruiting], MultiplayRecruitment::STATUSES[:in_progress] ]).recent.to_a
    @past_recruitments = base_query.where(status: [ MultiplayRecruitment::STATUSES[:closed], MultiplayRecruitment::STATUSES[:finished] ]).recent.to_a
  end

  def show
    @comments = @multiplay_recruitment.comments.includes(:user).oldest_first
    @comment = MultiplayRecruitmentComment.new if logged_in?
  end

  def new
    @multiplay_recruitment = MultiplayRecruitment.new
  end

  def create
    @multiplay_recruitment = current_user.multiplay_recruitments.build(multiplay_recruitment_params)

    if @multiplay_recruitment.save
      redirect_to @multiplay_recruitment, notice: t("multiplay_recruitments.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @multiplay_recruitment.update(multiplay_recruitment_params)
      redirect_to @multiplay_recruitment, notice: t("multiplay_recruitments.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @multiplay_recruitment.destroy
    redirect_to multiplay_recruitments_url, notice: t("multiplay_recruitments.destroy.success")
  end

  private
    def set_multiplay_recruitment
      @multiplay_recruitment = MultiplayRecruitment.find(params[:id])
    end

    def authorize_user
      unless @multiplay_recruitment.user == current_user
        redirect_to multiplay_recruitments_path, alert: t("multiplay_recruitments.errors.not_authorized_to_edit")
      end
    end

    def authorize_user_or_admin
      unless @multiplay_recruitment.user == current_user || current_user.admin?
        redirect_to multiplay_recruitments_path, alert: t("multiplay_recruitments.errors.not_authorized_to_delete")
      end
    end

    def multiplay_recruitment_params
      params.require(:multiplay_recruitment).permit(:title, :description, :stage_guid, :difficulty, :max_players, :start_time, :end_time, :status)
    end
end
