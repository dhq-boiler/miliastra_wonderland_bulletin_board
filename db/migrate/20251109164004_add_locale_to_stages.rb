class AddLocaleToStages < ActiveRecord::Migration[8.1]
  def change
    add_column :stages, :locale, :string
  end
end
