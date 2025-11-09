class ChangeStageGuidToString < ActiveRecord::Migration[8.1]
  def up
    change_column :stages, :stage_guid, :string
  end

  def down
    change_column :stages, :stage_guid, :integer
  end
end
