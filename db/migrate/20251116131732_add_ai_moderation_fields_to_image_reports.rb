class AddAiModerationFieldsToImageReports < ActiveRecord::Migration[8.1]
  def change
    add_column :image_reports, :ai_flagged, :boolean
    add_column :image_reports, :ai_confidence, :float
    add_column :image_reports, :ai_categories, :text
    add_column :image_reports, :ai_detected_at, :datetime
  end
end
