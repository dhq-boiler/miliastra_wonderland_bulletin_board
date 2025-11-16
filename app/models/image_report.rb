class ImageReport < ApplicationRecord
  # ステータス定数
  STATUSES = {
    pending: "pending",         # 未確認
    reviewed: "reviewed",       # レビュー済み（アクション不要）
    confirmed: "confirmed",     # 確認済み（不適切と判定）
    dismissed: "dismissed"      # 却下（問題なし）
  }.freeze

  # 通報理由カテゴリのキー（翻訳は I18n.t("app.image_report.categories.#{key}") で取得）
  REASON_CATEGORIES = %i[r18 r18g copyright spam harassment other].freeze

  # カテゴリの翻訳テキストを取得
  def self.category_text(key)
    I18n.t("app.image_report.categories.#{key}")
  end

  # カテゴリの一覧を取得（ビューで使用）
  def self.categories_for_select
    REASON_CATEGORIES.map { |key| [key, category_text(key)] }
  end

  # アソシエーション
  belongs_to :active_storage_attachment, class_name: "ActiveStorage::Attachment"
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  # バリデーション
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  validates :user_id, uniqueness: { scope: :active_storage_attachment_id,
                                   message: "は既にこの画像を通報しています" }

  # スコープ
  scope :pending, -> { where(status: STATUSES[:pending]) }
  scope :reviewed, -> { where(status: STATUSES[:reviewed]) }
  scope :confirmed, -> { where(status: STATUSES[:confirmed]) }
  scope :dismissed, -> { where(status: STATUSES[:dismissed]) }
  scope :recent, -> { order(created_at: :desc) }

  # 画像が不適切と判定されているか
  def self.image_reported?(attachment_id)
    where(active_storage_attachment_id: attachment_id)
      .where(status: [STATUSES[:pending], STATUSES[:confirmed]])
      .exists?
  end

  # 画像の通報数
  def self.report_count(attachment_id)
    where(active_storage_attachment_id: attachment_id).count
  end
end
