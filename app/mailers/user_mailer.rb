class UserMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@miliastra-wonderland-bulletin-board.com")

  def password_reset(user)
    @user = user
    @reset_url = edit_password_reset_url(@user.reset_password_token)

    mail to: @user.email, subject: "パスワードリセットのご案内"
  end
end
