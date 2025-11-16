class ImageReportsController < ApplicationController
  before_action :require_login
  before_action :set_attachment, only: :create

  def create
    # 既に通報済みかチェック
    existing_report = ImageReport.find_by(
      active_storage_attachment_id: @attachment.id,
      user_id: current_user.id
    )

    if existing_report
      respond_to do |format|
        format.json { render json: { error: "既にこの画像を通報しています" }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: root_path, alert: "既にこの画像を通報しています" }
      end
      return
    end

    @report = ImageReport.new(
      active_storage_attachment_id: @attachment.id,
      user_id: current_user.id,
      reason: params[:reason],
      status: ImageReport::STATUSES[:pending]
    )

    if @report.save
      # 最初の通報時のみ、画像のモデレーションを実行
      if ImageReport.where(active_storage_attachment_id: @attachment.id).count == 1
        ImageModerationJob.perform_later(@attachment.id)
      end

      respond_to do |format|
        format.json { render json: { success: true, message: "通報を受け付けました" }, status: :created }
        format.html { redirect_back fallback_location: root_path, notice: "通報を受け付けました" }
      end
    else
      respond_to do |format|
        format.json { render json: { error: @report.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: root_path, alert: @report.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def set_attachment
    @attachment = ActiveStorage::Attachment.find(params[:attachment_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { error: "画像が見つかりません" }, status: :not_found }
      format.html { redirect_back fallback_location: root_path, alert: "画像が見つかりません" }
    end
  end
end
