class StagesController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_stage, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update ]
  before_action :authorize_user_or_admin, only: [ :destroy ]

  def index
    @stages = Stage.includes(:user).recent

    # 各幻境のマルチプレイ募集件数を一括取得（N+1問題を回避）
    stage_guids = @stages.map(&:stage_guid).compact
    @multiplay_counts = MultiplayRecruitment.active
                                             .where(stage_guid: stage_guids)
                                             .group(:stage_guid)
                                             .count
  end

  def show
    # この幻境に対するマルチプレイ募集の件数を取得
    @multiplay_recruitments_count = MultiplayRecruitment.active.where(stage_guid: @stage.stage_guid).count
  end

  def new
    @stage = Stage.new
  end

  def create
    @stage = current_user.stages.build(stage_params)

    if @stage.save
      redirect_to @stage, notice: t("stages.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @stage.update(stage_params)
      redirect_to @stage, notice: t("stages.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stage.destroy
    redirect_to stages_url, notice: t("stages.destroy.success")
  end

  private
    def set_stage
      @stage = Stage.find(params[:id])
    end

    def authorize_user
      unless @stage.user == current_user
        redirect_to stages_path, alert: t("stages.errors.not_authorized_to_edit")
      end
    end

    def authorize_user_or_admin
      unless @stage.user == current_user || current_user.admin?
        redirect_to stages_path, alert: t("stages.errors.not_authorized_to_delete")
      end
    end

    def stage_params
      params.require(:stage).permit(:title, :description, :stage_guid, :difficulty, :tips, :locale)
    end
end
