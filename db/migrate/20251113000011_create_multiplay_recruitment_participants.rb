class CreateMultiplayRecruitmentParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :multiplay_recruitment_participants do |t|
      t.references :multiplay_recruitment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # ユーザーは同じ募集に1回のみ参加できる
    add_index :multiplay_recruitment_participants,
              [ :multiplay_recruitment_id, :user_id ],
              unique: true,
              name: "index_multiplay_participants_on_recruitment_and_user"
  end
end
