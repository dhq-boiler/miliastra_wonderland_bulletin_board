class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to stages_path, notice: 'アカウントが作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # パスワード変更の処理
    if params[:user][:current_password].present?
      # 現在のパスワードを確認
      unless @user.authenticate(params[:user][:current_password])
        @user.errors.add(:current_password, "が正しくありません")
        render :edit, status: :unprocessable_entity
        return
      end

      # 新しいパスワードが入力されている場合
      if params[:user][:password].present?
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
      else
        @user.errors.add(:password, "を入力してください")
        render :edit, status: :unprocessable_entity
        return
      end
    else
      # パスワード変更しない場合は、パスワードのバリデーションをスキップ
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
      params[:user].delete(:current_password)
    end

    if @user.update(profile_params)
      redirect_to profile_path, notice: 'プロファイルを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :nickname, :email, :password, :password_confirmation)
    end

    def profile_params
      params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
    end
end
