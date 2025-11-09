class AddDeletedAtToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at

    add_column :stages, :deleted_at, :datetime
    add_index :stages, :deleted_at

    add_column :multiplay_recruitments, :deleted_at, :datetime
    add_index :multiplay_recruitments, :deleted_at

    add_column :multiplay_recruitment_comments, :deleted_at, :datetime
    add_index :multiplay_recruitment_comments, :deleted_at
  end
end

