class ImageReport < ApplicationRecord
  # ステータス定数
  STATUSES = {
    pending: "pending",         # 未確認
    reviewed: "reviewed",       # レビュー済み（アクション不要）
    confirmed: "confirmed",     # 確認済み（不適切と判定）
    dismissed: "dismissed"      # 却下（問題なし）
  }.freeze

  # アソシエーション
  belongs_to :active_storage_attachment
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
