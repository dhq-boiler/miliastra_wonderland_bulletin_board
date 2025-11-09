class AddLocaleIndexToStages < ActiveRecord::Migration[8.1]
  def change
    add_index :stages, :locale
  end
end
