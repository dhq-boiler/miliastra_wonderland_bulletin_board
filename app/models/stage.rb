class Stage < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :description, presence: true
  validates :stage_guid, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true

  # 最新の投稿順に並べる
  scope :recent, -> { order(created_at: :desc) }
end
