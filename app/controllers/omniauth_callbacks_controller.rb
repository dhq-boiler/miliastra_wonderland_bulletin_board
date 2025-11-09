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
    redirect_to login_path, alert: "認証に失敗しました: #{params[:message]}"
  end
end

