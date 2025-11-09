class Stage < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :description, presence: true
  validates :stage_guid, presence: true, format: { with: /\A[1-9]\d*\z/, message: "は自然数（正の整数）で入力してください" }
  validates :user_id, presence: true

  # 最新の投稿順に並べる
  scope :recent, -> { order(created_at: :desc) }
end
