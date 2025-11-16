class CreateImageReports < ActiveRecord::Migration[8.1]
  def change
    create_table :image_reports do |t|
      t.references :active_storage_attachment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :reason
      t.string :status, default: "pending", null: false
      t.datetime :reviewed_at
      t.integer :reviewed_by_id

      t.timestamps
    end

    # インデックス追加
    add_index :image_reports, :status
    add_index :image_reports, :reviewed_by_id

    # 同じユーザーが同じ画像を複数回通報できないようにユニーク制約
    add_index :image_reports, [ :active_storage_attachment_id, :user_id ],
              unique: true,
              name: "index_image_reports_on_attachment_and_user"
  end
end
