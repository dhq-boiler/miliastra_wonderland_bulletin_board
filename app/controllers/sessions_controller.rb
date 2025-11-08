class SessionsController < ApplicationController
  def new
  end

  def create
    login = params[:login]
    # メールアドレスまたはユーザー名でユーザーを検索
    user = User.find_by(email: login) || User.find_by(username: login)

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to stages_path, notice: 'ログインしました。'
    else
      flash.now[:alert] = 'ユーザー名/メールアドレスまたはパスワードが正しくありません。'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'ログアウトしました。'
  end
end
