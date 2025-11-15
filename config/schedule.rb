# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# 環境変数の設定
set :environment, ENV.fetch("RAILS_ENV", "development")

# アプリケーションのルートパスを設定
set :path, "/rails"

# ログの出力先（絶対パス）
set :output, { error: "/rails/log/cron_error.log", standard: "/rails/log/cron.log" }

# 1分おきにマルチプレイ募集の自動終了タスクを実行
every 1.minute do
  rake "multiplay_recruitment:auto_close"
end

# 毎日深夜3時にデータベースバックアップを実行
every 1.day, at: '3:00 am' do
  command "/rails/bin/backup_database >> /rails/log/backup.log 2>&1"
end
