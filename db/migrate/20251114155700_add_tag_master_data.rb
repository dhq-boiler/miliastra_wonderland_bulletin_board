class AddTagMasterData < ActiveRecord::Migration[8.1]
  def up
    # デバイスタグ
    device_tags = [ "キーボードとマウス", "タッチスクリーン", "コントローラー" ]
    device_tags.each do |tag_name|
      Tag.find_or_create_by!(name: tag_name, category: "device")
    end

    # カテゴリータグ
    category_tags = [
      "アクションアドベンチャー", "FPS", "オンラインマルチ対戦", "TPS",
      "バトルロイヤル", "サバイバル", "経営シミュレーション", "ローグライク",
      "非対称型PVP", "共闘", "パーティ", "協力プレイ"
    ]
    category_tags.each do |tag_name|
      Tag.find_or_create_by!(name: tag_name, category: "category")
    end

    # その他のタグ
    other_tags = [
      "一人称視点", "俯瞰視点", "肩越し視点", "三人称視点", "固定カメラ",
      "カジュアル", "ノーマル", "ハード", "ハードコア", "難易度が変動"
    ]
    other_tags.each do |tag_name|
      Tag.find_or_create_by!(name: tag_name, category: "other")
    end
  end

  def down
    # ロールバック時はマスタデータを削除しない
    # （他のステージで使用されている可能性があるため）
  end
end
