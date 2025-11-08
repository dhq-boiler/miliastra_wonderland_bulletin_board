class CreateStages < ActiveRecord::Migration[8.1]
  def change
    create_table :stages do |t|
      t.string :title
      t.text :description
      t.string :stage_number
      t.string :difficulty
      t.text :tips

      t.timestamps
    end
  end
end
