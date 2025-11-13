class MultiplayRecruitment < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  has_many :comments, class_name: "MultiplayRecruitmentComment", dependent: :destroy
  has_many :participants, class_name: "MultiplayRecruitmentParticipant", dependent: :destroy
  has_many :participant_users, through: :participants, source: :user

  # ステータスの定義（英語で統一）
  STATUSES = {
    recruiting: "recruiting",      # 募集中
    in_progress: "in_progress",    # 開催中
    closed: "closed",              # 募集終了
    finished: "finished"           # 終了
  }.freeze

  validates :title, presence: true
  validates :description, presence: true
  validates :max_players, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  validates :stage_guid, format: { with: /\A[1-9]\d*\z/, message: "は自然数（正の整数）で入力してください" }, allow_blank: true

  # end_timeのデフォルト値を当日の24時（翌日0時）に設定
  before_validation :set_default_end_time, on: :create

  # 最新の投稿順に並べる
  scope :recent, -> { order(created_at: :desc) }
  scope :recruiting, -> { where(status: STATUSES[:recruiting]) }
  scope :active, -> { where(status: [ STATUSES[:recruiting], STATUSES[:in_progress] ]) }

  # 検索用スコープ
  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("title LIKE ? OR description LIKE ?", "%#{sanitize_sql_like(keyword)}%", "%#{sanitize_sql_like(keyword)}%")
  }

  scope :search_by_stage_guid, ->(stage_guid) {
    return all if stage_guid.blank?
    where(stage_guid: stage_guid)
  }

  scope :search_by_difficulty, ->(difficulty) {
    return all if difficulty.blank?
    where(difficulty: difficulty)
  }

  scope :search_by_status, ->(status) {
    return all if status.blank?
    where(status: status)
  }

  private

  def set_default_end_time
    self.end_time ||= Time.current.end_of_day
  end
end
