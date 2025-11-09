class UsersController < ApplicationController
  before_action :require_login, only: [ :edit, :update ]

  def show
    @user = User.find(params[:id])
    @stages = @user.stages.recent
    @multiplay_recruitments = @user.multiplay_recruitments.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to stages_path(locale: nil), notice: t('users.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # OAuthユーザーの場合、メールアドレスとパスワードの変更を禁止
    if @user.oauth_user?
      if params[:user][:email].present? && params[:user][:email] != @user.email
        @user.errors.add(:base, t('users.errors.oauth_email_readonly'))
        render :edit, status: :unprocessable_entity
        return
      end

      if params[:user][:password].present? || params[:user][:current_password].present?
        @user.errors.add(:base, t('users.errors.oauth_password_readonly'))
        render :edit, status: :unprocessable_entity
        return
      end

      # OAuthユーザーはニックネームのみ更新可能
      if @user.update(oauth_profile_params)
        redirect_to profile_path(locale: nil), notice: t('users.update.success')
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # 通常ユーザーのパスワード変更処理
      if params[:user][:current_password].present?
        # 現在のパスワードを確認
        unless @user.authenticate(params[:user][:current_password])
          @user.errors.add(:current_password, t('users.errors.current_password_incorrect'))
          render :edit, status: :unprocessable_entity
          return
        end

        # 新しいパスワードが入力されている場合
        if params[:user][:password].present?
          @user.password = params[:user][:password]
          @user.password_confirmation = params[:user][:password_confirmation]
        else
          @user.errors.add(:password, t('users.errors.new_password_required'))
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
        redirect_to profile_path(locale: nil), notice: t('users.update.success')
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :nickname, :email, :password, :password_confirmation, :locale)
    end

    def profile_params
      params.require(:user).permit(:nickname, :email, :password, :password_confirmation, :locale)
    end

    def oauth_profile_params
      params.require(:user).permit(:nickname, :locale)
    end
end
