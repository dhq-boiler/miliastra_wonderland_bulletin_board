require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "password_reset" do
    user = users(:one)
    user.generate_password_reset_token
    mail = UserMailer.password_reset(user)
    assert_equal "パスワードリセットのご案内", mail.subject
    assert_equal [ user.email ], mail.to
    # メールにパスワードリセットURLが含まれていることを確認
    assert_match /password_resets/, mail.body.parts.first.body.to_s
    assert_match user.display_name, mail.body.parts.first.body.to_s
  end
end
