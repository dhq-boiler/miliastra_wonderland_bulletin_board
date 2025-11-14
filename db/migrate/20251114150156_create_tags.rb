class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :slug
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :tags, [ :name, :category ], unique: true
    add_index :tags, :category
    add_index :tags, :deleted_at
  end
end
