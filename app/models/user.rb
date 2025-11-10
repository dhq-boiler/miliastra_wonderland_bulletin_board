class User < ApplicationRecord
  include SoftDeletable

  has_secure_password validations: false

  has_many :stages, dependent: :destroy
  has_many :multiplay_recruitments, dependent: :destroy
  has_many :multiplay_recruitment_comments, dependent: :destroy

  # 対応言語の定義
  AVAILABLE_LOCALES = %w[ja zh-CN zh-TW en ko es fr ru th vi de id pt tr it].freeze

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 6 }, if: -> { password_required? }
  validates :password_digest, presence: true, if: -> { password_required? }
  validates :nickname, length: { maximum: 50 }, allow_blank: true
  validates :locale, presence: true, inclusion: { in: AVAILABLE_LOCALES }
  validates :ingame_uid, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true

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

  # OmniAuth認証情報からユーザーを検索または作成
  def self.from_omniauth(auth)
    # カラムが存在するか確認（マイグレーション前のエラー防止）
    unless column_names.include?("provider") && column_names.include?("uid")
      raise "OAuth columns (provider, uid) are not yet migrated. Please run db:migrate."
    end

    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.username = generate_username_from_email(auth.info.email)
      user.nickname = auth.info.name
      user.password_digest = SecureRandom.hex(32) # ダミーのパスワードダイジェスト
      user.locale = I18n.default_locale.to_s # デフォルト言語を設定
    end
  end

  # OAuthユーザーかどうかを判定
  def oauth_user?
    return false unless self.class.column_names.include?("provider") && self.class.column_names.include?("uid")
    provider.present? && uid.present?
  end

  private

  # パスワードが必要かどうかを判定
  def password_required?
    !oauth_user? && (new_record? || password.present?)
  end

  # メールアドレスからユーザー名を生成
  def self.generate_username_from_email(email)
    base_username = email.split("@").first.gsub(/[^a-zA-Z0-9_]/, "_")
    # 最大20文字に制限（カウンターの余地を残すため）
    base_username = base_username[0..17] if base_username.length > 18
    username = base_username
    counter = 1

    while exists?(username: username)
      # カウンター付きでも30文字以内に収める
      username = "#{base_username[0..(27 - counter.to_s.length)]}#{counter}"
      counter += 1
    end

    username
  end
end
