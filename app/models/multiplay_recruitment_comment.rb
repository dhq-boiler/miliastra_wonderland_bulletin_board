class MultiplayRecruitmentComment < ApplicationRecord
  belongs_to :multiplay_recruitment
  belongs_to :user

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  # 最新のコメント順に並べる
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
end

