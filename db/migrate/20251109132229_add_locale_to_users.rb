class AddLocaleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :locale, :string, default: 'ja', null: false
    add_index :users, :locale
  end
end

