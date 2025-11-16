class MultiplayRecruitmentComment < ApplicationRecord
  include SoftDeletable

  belongs_to :multiplay_recruitment
  belongs_to :user
  has_many_attached :images

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  validate :validate_images

  # 最新のコメント順に並べる
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

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
end
