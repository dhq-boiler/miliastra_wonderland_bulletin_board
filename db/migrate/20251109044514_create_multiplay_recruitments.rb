class CreateMultiplayRecruitments < ActiveRecord::Migration[8.1]
  def change
    create_table :multiplay_recruitments do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :stage_guid
      t.string :difficulty
      t.integer :max_players, default: 4
      t.datetime :start_time
      t.string :status, default: "募集中"
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

