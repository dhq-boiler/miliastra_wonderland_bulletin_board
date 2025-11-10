class AddIngameUidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ingame_uid, :string
  end
end
