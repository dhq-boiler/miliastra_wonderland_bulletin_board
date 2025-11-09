class ChangeEmailIndexToAllowNulls < ActiveRecord::Migration[8.1]
  def change
    # 既存のユニークインデックスを削除
    remove_index :users, :email

    # 条件付きユニークインデックスを追加（emailが空でない場合のみユニーク）
    add_index :users, :email, unique: true, where: "email IS NOT NULL AND email != ''"
  end
end
