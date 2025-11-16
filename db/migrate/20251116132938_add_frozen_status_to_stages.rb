class AddFrozenStatusToStages < ActiveRecord::Migration[8.1]
  def change
    add_column :stages, :frozen_at, :datetime
    add_column :stages, :frozen_reason, :text
    add_column :stages, :frozen_type, :string
  end
end
