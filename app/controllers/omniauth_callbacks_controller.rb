class OmniauthCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    if user.persisted?
      # 既存のユーザー
      session[:user_id] = user.id
      redirect_to stages_path, notice: "Googleアカウントでログインしました。"
    elsif user.save
      # 新規ユーザー作成成功
      session[:user_id] = user.id
      redirect_to stages_path, notice: "Googleアカウントでアカウントを作成しました。"
    else
      # エラー処理
      redirect_to login_path, alert: "ログインに失敗しました: #{user.errors.full_messages.join(", ")}"
    end
  end

  def failure
    error_type = params[:error_reason] || params[:error] || "unknown"
    error_message = params[:error_description] || params[:message] || "不明なエラー"

    Rails.logger.error "OAuth認証失敗: #{error_type} - #{error_message}"
    Rails.logger.error "リクエストパラメータ: #{params.inspect}"

    redirect_to login_path, alert: "認証に失敗しました: #{error_message}"
  end
end
