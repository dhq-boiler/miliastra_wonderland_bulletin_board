class Tag < ApplicationRecord
  include SoftDeletable

  # Category constants
  CATEGORIES = %w[device category other].freeze
  DEVICE_TAGS = [ "キーボードとマウス", "タッチスクリーン", "コントローラー" ].freeze
  CATEGORY_TAGS = [
    "アクションアドベンチャー", "FPS", "オンラインマルチ対戦", "TPS",
    "バトルロイヤル", "サバイバル", "経営シミュレーション", "ローグライク",
    "非対称型PVP", "共闘", "パーティ", "協力プレイ"
  ].freeze
  OTHER_TAGS = [
    "一人称視点", "俯瞰視点", "肩越し視点", "三人称視点", "固定カメラ",
    "カジュアル", "ノーマル", "ハード", "ハードコア", "難易度が変動"
  ].freeze

  # Associations
  has_many :stage_tags, dependent: :destroy
  has_many :stages, through: :stage_tags

  # Validations
  validates :name, presence: true, uniqueness: { scope: :category, case_sensitive: false }
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :device, -> { where(category: "device") }
  scope :category_type, -> { where(category: "category") }
  scope :other, -> { where(category: "other") }
  scope :ordered, -> { order(:category, :name) }

  # Callbacks
  before_validation :generate_slug

  def self.category_text(category)
    case category
    when "device"
      I18n.t("tags.categories.device")
    when "category"
      I18n.t("tags.categories.category")
    when "other"
      I18n.t("tags.categories.other")
    else
      category
    end
  end

  def category_text
    self.class.category_text(category)
  end

  private

  def generate_slug
    self.slug = name&.parameterize if slug.blank? && name.present?
  end
end
