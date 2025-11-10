class AddEndTimeToMultiplayRecruitments < ActiveRecord::Migration[8.1]
  def change
    add_column :multiplay_recruitments, :end_time, :datetime
  end
end
