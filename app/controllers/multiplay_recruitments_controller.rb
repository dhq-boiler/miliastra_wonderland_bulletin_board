class MultiplayRecruitmentsController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_multiplay_recruitment, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update ]
  before_action :authorize_user_or_admin, only: [ :destroy ]

  def index
    # 検索パラメータを取得
    @search_keyword = params[:keyword]
    @search_stage_guid = params[:stage_guid]
    @search_difficulty = params[:difficulty]
    @search_status = params[:status]

    # ステージ選択用データ（ログイン時のみ）
    if logged_in?
      @my_stages = current_user.stages.select(:id, :title, :stage_guid, :locale, :user_id).recent
      @other_stages = Stage.where.not(user_id: current_user.id).select(:id, :title, :stage_guid, :locale, :user_id).recent
    else
      @all_stages = Stage.select(:id, :title, :stage_guid, :locale, :user_id).recent
    end

    # 基本クエリに検索条件を適用
    base_query = MultiplayRecruitment.includes(:user)
                                     .left_joins(:comments)
                                     .group(:id)
                                     .select("multiplay_recruitments.*, COUNT(multiplay_recruitment_comments.id) as comments_count")
                                     .search_by_keyword(@search_keyword)
                                     .search_by_stage_guid(@search_stage_guid)
                                     .search_by_difficulty(@search_difficulty)

    # ステータスで検索条件がある場合はそれを使用、なければデフォルトの分類
    if @search_status.present?
      @active_recruitments = base_query.search_by_status(@search_status).recent.to_a
      @past_recruitments = []
    else
      @active_recruitments = base_query.where(status: [ MultiplayRecruitment::STATUSES[:recruiting], MultiplayRecruitment::STATUSES[:in_progress] ]).recent.to_a
      @past_recruitments = base_query.where(status: [ MultiplayRecruitment::STATUSES[:closed], MultiplayRecruitment::STATUSES[:finished] ]).recent.to_a
    end
  end

  def show
    @comments = @multiplay_recruitment.comments.includes(:user).oldest_first

    # 管理者以外は凍結されたコメントを非表示
    unless logged_in? && current_user.admin?
      @comments = @comments.not_frozen
    end

    @comment = MultiplayRecruitmentComment.new if logged_in?
  end

  def new
    @multiplay_recruitment = MultiplayRecruitment.new
    @my_stages = current_user.stages.select(:id, :title, :stage_guid, :locale, :user_id).recent
    @other_stages = Stage.where.not(user_id: current_user.id).select(:id, :title, :stage_guid, :locale, :user_id).recent
  end

  def create
    @multiplay_recruitment = current_user.multiplay_recruitments.build(multiplay_recruitment_params)

    if @multiplay_recruitment.save
      redirect_to @multiplay_recruitment, notice: t("multiplay_recruitments.create.success")
    else
      @my_stages = current_user.stages.select(:id, :title, :stage_guid, :locale, :user_id).recent
      @other_stages = Stage.where.not(user_id: current_user.id).select(:id, :title, :stage_guid, :locale, :user_id).recent
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @my_stages = current_user.stages.select(:id, :title, :stage_guid, :locale, :user_id).recent
    @other_stages = Stage.where.not(user_id: current_user.id).select(:id, :title, :stage_guid, :locale, :user_id).recent
  end

  def update
    if @multiplay_recruitment.update(multiplay_recruitment_params)
      redirect_to @multiplay_recruitment, notice: t("multiplay_recruitments.update.success")
    else
      @my_stages = current_user.stages.select(:id, :title, :stage_guid, :locale, :user_id).recent
      @other_stages = Stage.where.not(user_id: current_user.id).select(:id, :title, :stage_guid, :locale, :user_id).recent
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
