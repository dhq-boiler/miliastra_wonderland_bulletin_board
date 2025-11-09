class AddNicknameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :nickname, :string
  end
end
