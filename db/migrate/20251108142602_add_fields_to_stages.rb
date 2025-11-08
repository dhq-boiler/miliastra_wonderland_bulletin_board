class AddFieldsToStages < ActiveRecord::Migration[8.1]
  def change
    add_column :stages, :stage_guid, :integer
    add_column :stages, :user_id, :integer

    add_index :stages, :stage_guid
    add_index :stages, :user_id
  end
end
