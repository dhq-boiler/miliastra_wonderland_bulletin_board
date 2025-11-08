# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# WARNING: These sample users use weak passwords and are for development/testing only.
# DO NOT use these in production or change the passwords to strong ones.

# サンプルユーザーの作成
puts "Creating sample users..."
user1 = User.find_or_create_by!(username: "admin") do |u|
  u.email = "admin@example.com"
  u.password = "password"
  u.password_confirmation = "password"
end

user2 = User.find_or_create_by!(username: "player1") do |u|
  u.email = "player1@example.com"
  u.password = "password"
  u.password_confirmation = "password"
end

puts "Users created: #{User.count}"

# サンプルステージの作成
puts "Creating sample stages..."

Stage.find_or_create_by!(stage_guid: 1001, user: user1) do |s|
  s.title = "第1章 幻想の森 - 初心者向け攻略"
  s.stage_number = "1-1"
  s.difficulty = "簡単"
  s.description = "ゲームの最初のステージです。基本的な操作を覚えながら進めましょう。\n\n敵は弱いですが、落とし穴に注意が必要です。"
  s.tips = "ジャンプのタイミングをしっかり覚えましょう。\n最初のチェックポイントまでは慎重に進むことをおすすめします。"
end

Stage.find_or_create_by!(stage_guid: 1002, user: user2) do |s|
  s.title = "第2章 氷の洞窟 - 滑る床の攻略法"
  s.stage_number = "2-1"
  s.difficulty = "普通"
  s.description = "床が滑りやすいステージです。慣性を考慮した移動が必要になります。\n\n途中に出てくる氷のブロックは、特定の順序で壊す必要があります。"
  s.tips = "滑る床では小刻みにジャンプすると制御しやすいです。\n氷のブロックは左から順番に壊していくのが安全です。"
end

Stage.find_or_create_by!(stage_guid: 2001, user: user1) do |s|
  s.title = "ボスステージ - 炎の守護者攻略"
  s.stage_number = "Boss-1"
  s.difficulty = "難しい"
  s.description = "第一部のボスステージです。炎の守護者との戦闘になります。\n\n攻撃パターンは3種類あり、それぞれに対応した回避方法が必要です。"
  s.tips = "最初の10秒は様子見して攻撃パターンを覚えましょう。\n炎の柱が出る前に予備動作があるので、それを見逃さないように。\n回復アイテムはステージ左右の端に隠されています。"
end

puts "Stages created: #{Stage.count}"
puts "Seed data creation completed!"
