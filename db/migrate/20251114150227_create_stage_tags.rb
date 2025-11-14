class CreateStageTags < ActiveRecord::Migration[8.1]
  def change
    create_table :stage_tags do |t|
      t.references :stage, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :stage_tags, [ :stage_id, :tag_id ], unique: true
    add_index :stage_tags, :deleted_at
  end
end
