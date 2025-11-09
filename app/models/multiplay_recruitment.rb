class MultiplayRecruitment < ApplicationRecord
  belongs_to :user
  has_many :comments, class_name: "MultiplayRecruitmentComment", dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :max_players, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }
  validates :status, presence: true, inclusion: { in: %w[募集中 募集終了 開催中 終了] }
  validates :stage_guid, format: { with: /\A[1-9]\d*\z/, message: "は自然数（正の整数）で入力してください" }, allow_blank: true

  # 最新の投稿順に並べる
  scope :recent, -> { order(created_at: :desc) }
  scope :recruiting, -> { where(status: "募集中") }
  scope :active, -> { where(status: ["募集中", "開催中"]) }
end

