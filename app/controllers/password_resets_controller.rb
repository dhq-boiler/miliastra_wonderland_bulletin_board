class PasswordResetsController < ApplicationController
  before_action :find_user_by_token, only: [ :edit, :update ]
  before_action :check_token_expiration, only: [ :edit, :update ]

  # パスワードリセット申請フォーム
  def new
  end

  # パスワードリセットメール送信
  def create
    @user = User.find_by(email: params[:email])

    if @user&.email.present?
      @user.generate_password_reset_token
      UserMailer.password_reset(@user).deliver_now
      redirect_to login_path, notice: t('password_resets.create.success')
    else
      flash.now[:alert] = t('password_resets.create.success')
      render :new, status: :unprocessable_entity
    end
  end

  # パスワードリセットフォーム
  def edit
  end

  # パスワード更新
  def update
    if params[:user][:password].blank?
      flash.now[:alert] = t('password_resets.update.password_blank')
      render :edit, status: :unprocessable_entity
    elsif @user.update(password_params)
      @user.clear_password_reset_token
      redirect_to login_path, notice: t('password_resets.update.success')
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user_by_token
    @user = User.find_by(reset_password_token: params[:id])
    unless @user
      redirect_to new_password_reset_path, alert: t('password_resets.errors.invalid_token')
    end
  end

  def check_token_expiration
    unless @user.password_reset_token_valid?
      redirect_to new_password_reset_path, alert: t('password_resets.errors.token_expired')
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
