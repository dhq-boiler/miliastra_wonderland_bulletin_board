class AddFrozenStatusToMultiplayRecruitmentComments < ActiveRecord::Migration[8.1]
  def change
    add_column :multiplay_recruitment_comments, :frozen_at, :datetime
    add_column :multiplay_recruitment_comments, :frozen_reason, :text
    add_column :multiplay_recruitment_comments, :frozen_type, :string
  end
end
