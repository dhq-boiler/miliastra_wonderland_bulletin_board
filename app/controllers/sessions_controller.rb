class SessionsController < ApplicationController
  def new
  end

  def create
    login = params[:login]&.strip
    password = params[:password]

    # デバッグ情報（開発環境のみ）
    Rails.logger.info "Login attempt with: #{login}"

    # メールアドレスまたはユーザー名でユーザーを検索
    user = User.find_by(email: login) || User.find_by(username: login)

    Rails.logger.info "User found: #{user.present?}"

    if user && user.authenticate(password)
      session[:user_id] = user.id
      redirect_to stages_path, notice: "ログインしました。"
    else
      Rails.logger.info "Authentication failed - User: #{user.present?}, Password valid: #{user&.authenticate(password)}"
      flash.now[:alert] = "ユーザー名/メールアドレスまたはパスワードが正しくありません。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "ログアウトしました。"
  end
end
