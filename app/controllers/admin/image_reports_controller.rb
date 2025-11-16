module Admin
  class ImageReportsController < ApplicationController
    before_action :require_login
    before_action :require_admin
    before_action :set_report, only: [ :show, :confirm, :dismiss ]

    def index
      @status_filter = params[:status] || "all"

      @reports = ImageReport.includes(:user, :active_storage_attachment, :reviewed_by)
                           .recent

      # ステータスでフィルタリング
      case @status_filter
      when "pending"
        @reports = @reports.pending
      when "confirmed"
        @reports = @reports.confirmed
      when "dismissed"
        @reports = @reports.dismissed
      when "reviewed"
        @reports = @reports.reviewed
      end

      @reports = @reports.limit(100)

      # 統計情報
      @stats = {
        total: ImageReport.count,
        pending: ImageReport.pending.count,
        confirmed: ImageReport.confirmed.count,
        dismissed: ImageReport.dismissed.count,
        reviewed: ImageReport.reviewed.count
      }
    end

    def show
      @attachment = @report.active_storage_attachment
      @reported_user = @attachment.record.user if @attachment.record.respond_to?(:user)
      @all_reports = ImageReport.where(active_storage_attachment_id: @attachment.id)
                                .includes(:user)
                                .recent
    end

    def confirm
      @report.update!(
        status: ImageReport::STATUSES[:confirmed],
        reviewed_by: current_user,
        reviewed_at: Time.current
      )

      redirect_to admin_image_reports_path, notice: "通報を確認済みにしました（不適切と判定）"
    end

    def dismiss
      @report.update!(
        status: ImageReport::STATUSES[:dismissed],
        reviewed_by: current_user,
        reviewed_at: Time.current
      )

      redirect_to admin_image_reports_path, notice: "通報を却下しました（問題なし）"
    end

    private

    def set_report
      @report = ImageReport.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_image_reports_path, alert: "通報が見つかりません"
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "管理者のみアクセス可能です"
      end
    end
  end
end
