class StagesController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_stage, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update ]
  before_action :authorize_user_or_admin, only: [ :destroy ]

  def index
    # 検索パラメータの設定
    @search_keyword = params[:keyword]
    @search_stage_guid = params[:stage_guid]
    @search_device_tag_ids = params[:device_tag_ids]&.reject(&:blank?)
    @search_category_tag_ids = params[:category_tag_ids]&.reject(&:blank?)
    @search_other_tag_ids = params[:other_tag_ids]&.reject(&:blank?)

    # タグをカテゴリ別に取得
    @device_tags = Tag.device.ordered
    @category_tags = Tag.category_type.ordered
    @other_tags = Tag.other.ordered

    # 検索クエリの構築
    @stages = Stage.includes(:user, :tags)
                   .search_by_keyword(@search_keyword)
                   .search_by_stage_guid(@search_stage_guid)
                   .search_by_device_tags(@search_device_tag_ids)
                   .search_by_category_tags(@search_category_tag_ids)
                   .search_by_other_tags(@search_other_tag_ids)
                   .recent

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
    load_tags
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
    load_tags
  end

  def update
    # 削除対象の画像を処理
    if params[:stage][:remove_image].present?
      params[:stage][:remove_image].each do |image_id|
        image = @stage.images.find(image_id)
        image.purge
      end
    end

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
      @stage = Stage.includes(:tags).find(params[:id])
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

    def load_tags
      @device_tags = Tag.device.ordered
      @category_tags = Tag.category_type.ordered
      @other_tags = Tag.other.ordered
    end

    def stage_params
      params.require(:stage).permit(:title, :description, :stage_guid, :difficulty, :tips, :locale, tag_ids: [], images: [])
    end
end
