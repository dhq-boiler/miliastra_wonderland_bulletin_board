class StageTag < ApplicationRecord
  include SoftDeletable

  belongs_to :stage
  belongs_to :tag

  validates :stage_id, uniqueness: { scope: :tag_id }
end
