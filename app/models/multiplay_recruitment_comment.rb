class MultiplayRecruitmentComment < ApplicationRecord
  include SoftDeletable

  # 凍結タイプの定義
  FROZEN_TYPES = {
    temporary: "temporary",  # 仮凍結（AI判定）
    permanent: "permanent"   # 永久凍結（管理者判定）
  }.freeze

  belongs_to :multiplay_recruitment
  belongs_to :user
  has_many_attached :images

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  validate :validate_images

  # 画像の自動モデレーションを実行
  after_create_commit :enqueue_image_moderation_jobs

  # 最新のコメント順に並べる
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  # 凍結関連スコープ
  scope :frozen, -> { where.not(frozen_at: nil) }
  scope :not_frozen, -> { where(frozen_at: nil) }
  scope :temporarily_frozen, -> { where(frozen_type: FROZEN_TYPES[:temporary]) }
  scope :permanently_frozen, -> { where(frozen_type: FROZEN_TYPES[:permanent]) }

  # 凍結ステータスの確認
  def frozen?
    frozen_at.present?
  end

  def temporarily_frozen?
    frozen? && frozen_type == FROZEN_TYPES[:temporary]
  end

  def permanently_frozen?
    frozen? && frozen_type == FROZEN_TYPES[:permanent]
  end

  # コメントを凍結
  def freeze_post!(type: :temporary, reason: nil)
    update!(
      frozen_at: Time.current,
      frozen_type: FROZEN_TYPES[type],
      frozen_reason: reason
    )
  end

  # 凍結を解除
  def unfreeze!
    update!(
      frozen_at: nil,
      frozen_type: nil,
      frozen_reason: nil
    )
  end

  private

  # 画像のバリデーション
  def validate_images
    return unless images.attached?

    # 最大4枚まで
    if images.count > 4
      errors.add(:images, "は最大4枚までアップロードできます")
    end

    # 各画像のサイズチェック（6MB以下）
    images.each do |image|
      if image.byte_size > 6.megabytes
        errors.add(:images, "#{image.filename}のサイズが大きすぎます（最大6MB）")
      end

      # 画像の形式チェック
      unless image.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
        errors.add(:images, "#{image.filename}は対応していない形式です（JPEG, PNG, GIF, WebPのみ）")
      end
    end
  end

  # アップロードされた画像の自動モデレーションジョブをエンキュー
  def enqueue_image_moderation_jobs
    return unless images.attached?

    images.each do |image|
      ImageModerationJob.perform_later(image.id)
    end
  end
end
