class CreateMultiplayRecruitmentComments < ActiveRecord::Migration[8.1]
  def change
    create_table :multiplay_recruitment_comments do |t|
      t.references :multiplay_recruitment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
    add_index :multiplay_recruitment_comments, :created_at
  end
end
