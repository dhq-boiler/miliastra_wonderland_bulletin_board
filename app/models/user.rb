class User < ApplicationRecord
  has_secure_password

  has_many :stages, dependent: :destroy
  has_many :multiplay_recruitments, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :nickname, length: { maximum: 50 }, allow_blank: true

  # 表示名を取得（ニックネームがあればニックネーム、なければユーザー名）
  def display_name
    nickname.presence || username
  end

  # 管理者かどうかを判定
  def admin?
    admin
  end

  # パスワードリセットトークンを生成
  def generate_password_reset_token
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!(validate: false)
  end

  # パスワードリセットトークンの有効期限を確認（2時間）
  def password_reset_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > 2.hours.ago
  end

  # パスワードリセットトークンをクリア
  def clear_password_reset_token
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save!(validate: false)
  end
end
