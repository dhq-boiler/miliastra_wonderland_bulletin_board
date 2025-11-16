module Admin
  class UsersController < ApplicationController
    before_action :require_login
    before_action :require_admin
    before_action :set_user, only: [ :show, :suspend, :unsuspend, :ban, :unban ]

    def index
      @status_filter = params[:status] || "all"

      @users = User.order(created_at: :desc)

      # ステータスでフィルタリング
      case @status_filter
      when "active"
        @users = @users.select(&:active?)
      when "suspended"
        @users = @users.select(&:suspended?)
      when "banned"
        @users = @users.select(&:banned?)
      when "admin"
        @users = @users.where(admin: true)
      end

      @users = @users.first(100)

      # 統計情報
      @stats = {
        total: User.count,
        active: User.all.count { |u| u.active? },
        suspended: User.all.count { |u| u.suspended? },
        banned: User.all.count { |u| u.banned? },
        admin: User.where(admin: true).count
      }
    end

    def show
      @stages = @user.stages.recent.limit(10)
      @comments = @user.multiplay_recruitment_comments.order(created_at: :desc).limit(10)
      @reports_made = ImageReport.where(user_id: @user.id).order(created_at: :desc).limit(10)

      # このユーザーの画像に対する通報
      @reports_received = ImageReport
        .joins(active_storage_attachment: :blob)
        .where(active_storage_attachments: { record_type: [ "Stage", "MultiplayRecruitmentComment" ] })
        .where("active_storage_attachments.record_id IN (
          SELECT id FROM stages WHERE user_id = :user_id
          UNION
          SELECT id FROM multiplay_recruitment_comments WHERE user_id = :user_id
        )", user_id: @user.id)
        .order(created_at: :desc)
        .limit(10)
    end

    def suspend
      duration_days = params[:duration]&.to_i || 7
      reason = params[:reason]

      @user.suspend!(reason: reason, duration: duration_days.days)

      redirect_to admin_user_path(@user), notice: "#{@user.display_name}を#{duration_days}日間停止しました"
    end

    def unsuspend
      @user.unsuspend!

      redirect_to admin_user_path(@user), notice: "#{@user.display_name}の停止を解除しました"
    end

    def ban
      reason = params[:reason]

      @user.ban!(reason: reason)

      redirect_to admin_user_path(@user), notice: "#{@user.display_name}をBANしました"
    end

    def unban
      @user.unban!

      redirect_to admin_user_path(@user), notice: "#{@user.display_name}のBANを解除しました"
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_users_path, alert: "ユーザーが見つかりません"
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "管理者のみアクセス可能です"
      end
    end
  end
end
