namespace :multiplay_recruitment do
  desc "終了予定時刻を過ぎた募集を自動的に終了状態に更新する"
  task auto_close: :environment do
    current_time = Time.current

    # 終了していない募集（募集中、開催中）を取得
    active_recruitments = MultiplayRecruitment.where(status: [ "募集中", "開催中" ])

    closed_count = 0

    active_recruitments.each do |recruitment|
      should_close = false

      if recruitment.end_time.present?
        # end_timeが設定されている場合、それを過ぎていたら終了
        should_close = true if current_time >= recruitment.end_time
      elsif recruitment.start_time.present?
        # end_timeが設定されていない場合、start_timeの翌日0時を過ぎていたら終了
        next_day_midnight = recruitment.start_time.end_of_day
        should_close = true if current_time >= next_day_midnight
      end

      if should_close
        recruitment.update(status: "終了")
        closed_count += 1
        puts "募集ID #{recruitment.id} を終了しました"
      end
    end

    puts "#{closed_count}件の募集を終了しました（実行時刻: #{current_time}）"
  end
end
