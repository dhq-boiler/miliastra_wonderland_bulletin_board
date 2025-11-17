class ModifyImageReportsForGem < ActiveRecord::Migration[8.1]
  def change
    # Allow user_id to be null for AI-generated reports
    change_column_null :image_reports, :user_id, true
  end
end
