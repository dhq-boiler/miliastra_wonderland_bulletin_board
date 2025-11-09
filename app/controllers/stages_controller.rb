class StagesController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_stage, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update ]
  before_action :authorize_user_or_admin, only: [ :destroy ]

  def index
    @stages = Stage.includes(:user).recent
  end

  def show
  end

  def new
    @stage = Stage.new
  end

  def create
    @stage = current_user.stages.build(stage_params)

    if @stage.save
      redirect_to @stage, notice: "幻境紹介が投稿されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @stage.update(stage_params)
      redirect_to @stage, notice: "ステージ紹介が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stage.destroy
    redirect_to stages_url, notice: "幻境紹介が削除されました。"
  end

  private
    def set_stage
      @stage = Stage.find(params[:id])
    end

    def authorize_user
      unless @stage.user == current_user
        redirect_to stages_path, alert: "他のユーザーの投稿は編集できません。"
      end
    end

    def authorize_user_or_admin
      unless @stage.user == current_user || current_user.admin?
        redirect_to stages_path, alert: "他のユーザーの投稿は削除できません。"
      end
    end

    def stage_params
      params.require(:stage).permit(:title, :description, :stage_guid, :difficulty, :tips)
    end
end
