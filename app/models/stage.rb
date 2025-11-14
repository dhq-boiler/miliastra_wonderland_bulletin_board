
class Stage < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  has_many :stage_tags, dependent: :destroy
  has_many :tags, through: :stage_tags

  validates :title, presence: true
  validates :description, presence: true
  validates :stage_guid, presence: true, format: { with: /\A[1-9]\d*\z/, message: "は自然数（正の整数）で入力してください" }
  validates :user_id, presence: true
  validates :locale, presence: true, inclusion: { in: User::AVAILABLE_LOCALES }

  # 作成時にユーザーのlocaleを設定
  before_validation :set_locale_from_user, on: :create

  # 最新の投稿順に並べる（更新時間優先、次に作成時間）
  scope :recent, -> { order(updated_at: :desc, created_at: :desc) }

  # タグによる検索スコープ
  scope :search_by_tag_ids, ->(tag_ids) {
    return all if tag_ids.blank?
    joins(:stage_tags).where(stage_tags: { tag_id: tag_ids }).distinct
  }

  scope :search_by_device_tags, ->(tag_ids) {
    return all if tag_ids.blank?
    joins(:stage_tags).joins(:tags).where(stage_tags: { tag_id: tag_ids }, tags: { category: "device" }).distinct
  }

  scope :search_by_category_tags, ->(tag_ids) {
    return all if tag_ids.blank?
    joins(:stage_tags).joins(:tags).where(stage_tags: { tag_id: tag_ids }, tags: { category: "category" }).distinct
  }

  scope :search_by_other_tags, ->(tag_ids) {
    return all if tag_ids.blank?
    joins(:stage_tags).joins(:tags).where(stage_tags: { tag_id: tag_ids }, tags: { category: "other" }).distinct
  }

  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("title LIKE ? OR description LIKE ?", "%#{sanitize_sql_like(keyword)}%", "%#{sanitize_sql_like(keyword)}%")
  }

  # 難易度の翻訳を取得
  def difficulty_text
    return nil if difficulty.blank?
    I18n.t("app.stages.form.difficulty_#{difficulty}")
  end

  private

  # ユーザーのlocaleをstageに設定
  def set_locale_from_user
    self.locale ||= user&.locale
  end
end
