namespace :admin do
  desc "Create an admin user"
  task create: :environment do
    puts "\n=========================================="
    puts "   管理者ユーザー作成ツール"
    puts "=========================================="
    puts "このツールは開発環境・本番環境で管理者を作成できます。"
    puts "※ 入力した情報はログに記録されません。"
    puts "※ 管理者は全ての投稿を削除できる権限を持ちます。\n\n"

    # メールアドレスの入力（任意）
    print "メールアドレスを入力してください（任意、Enterでスキップ）: "
    email = STDIN.gets.chomp
    email = nil if email.blank?

    # 既存ユーザーチェック（メールアドレスが入力された場合）
    if email.present? && User.exists?(email: email)
      puts "✗ このメールアドレスは既に登録されています。"
      exit 1
    end

    # ユーザー名の入力
    print "ユーザー名を入力してください (3〜20文字): "
    username = STDIN.gets.chomp

    if username.blank?
      puts "✗ ユーザー名は必須です。"
      exit 1
    end

    if username.length < 3 || username.length > 20
      puts "✗ ユーザー名は3〜20文字で入力してください。"
      exit 1
    end

    # 既存ユーザー名チェック
    if User.exists?(username: username)
      puts "✗ このユーザー名は既に使用されています。"
      exit 1
    end

    # パスワードの入力
    print "パスワードを入力してください (6文字以上): "
    password = STDIN.noecho(&:gets).chomp
    puts ""

    if password.length < 6
      puts "✗ パスワードは6文字以上で入力してください。"
      exit 1
    end

    # パスワード確認
    print "パスワードを再入力してください: "
    password_confirmation = STDIN.noecho(&:gets).chomp
    puts ""

    if password != password_confirmation
      puts "✗ パスワードが一致しません。"
      exit 1
    end

    # 管理者ユーザー作成
    begin
      user = User.create!(
        email: email,
        username: username,
        password: password,
        password_confirmation: password_confirmation,
        admin: true
      )

      puts "\n✓ 管理者ユーザーが正常に作成されました！"
      puts "=========================================="
      puts "  メールアドレス: #{user.email.presence || '(未設定)'}"
      puts "  ユーザー名: #{user.username}"
      puts "  権限: 管理者"
      puts "  作成日時: #{user.created_at}"
      puts "=========================================="
      puts "\nこのユーザーでログインできます。"
      puts "管理者として全ての投稿を削除できる権限があります。"
    rescue ActiveRecord::RecordInvalid => e
      puts "\n✗ ユーザー作成に失敗しました:"
      e.record.errors.full_messages.each do |message|
        puts "  - #{message}"
      end
      exit 1
    end
  end

  desc "List all users (admin tool)"
  task list: :environment do
    puts "\n=========================================="
    puts "   登録ユーザー一覧"
    puts "=========================================="

    users = User.order(created_at: :desc)

    if users.empty?
      puts "ユーザーが登録されていません。"
    else
      users.each_with_index do |user, index|
        admin_badge = user.admin? ? " [管理者]" : ""
        puts "\n[#{index + 1}] #{user.username}#{admin_badge}"
        puts "    Email: #{user.email.presence || '(未設定)'}"
        puts "    登録日: #{user.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
        puts "    投稿数: #{user.stages.count}"
      end
      puts "\n合計: #{users.count}人 (管理者: #{users.where(admin: true).count}人)"
    end
    puts "=========================================="
  end

  desc "Delete a user by username or email (admin tool)"
  task delete: :environment do
    puts "\n=========================================="
    puts "   ユーザー削除ツール"
    puts "=========================================="
    puts "⚠️  警告: この操作は取り消せません！\n\n"

    print "削除するユーザーのユーザー名またはメールアドレスを入力: "
    identifier = STDIN.gets.chomp

    if identifier.blank?
      puts "✗ ユーザー名またはメールアドレスを入力してください。"
      exit 1
    end

    user = User.find_by(username: identifier) || User.find_by(email: identifier)

    if user.nil?
      puts "✗ ユーザーが見つかりませんでした。"
      exit 1
    end

    puts "\n削除対象ユーザー:"
    puts "  ユーザー名: #{user.username}"
    puts "  メール: #{user.email.presence || '(未設定)'}"
    puts "  権限: #{user.admin? ? '管理者' : '一般ユーザー'}"
    puts "  投稿数: #{user.stages.count}"
    puts "\n⚠️  このユーザーと関連する全ての投稿が削除されます。"
    print "\n本当に削除しますか? (yes/no): "

    confirmation = STDIN.gets.chomp.downcase

    if confirmation == "yes"
      username = user.username
      user.destroy!
      puts "\n✓ ユーザー '#{username}' を削除しました。"
    else
      puts "\n削除をキャンセルしました。"
    end
  end

  desc "Change user password (admin tool)"
  task change_password: :environment do
    puts "\n=========================================="
    puts "   パスワード変更ツール"
    puts "=========================================="

    print "ユーザー名またはメールアドレスを入力: "
    identifier = STDIN.gets.chomp

    if identifier.blank?
      puts "✗ ユーザー名またはメールアドレスを入力してください。"
      exit 1
    end

    user = User.find_by(username: identifier) || User.find_by(email: identifier)

    if user.nil?
      puts "✗ ユーザーが見つかりませんでした。"
      exit 1
    end

    admin_badge = user.admin? ? " [管理者]" : ""
    puts "\n対象ユーザー: #{user.username}#{admin_badge} (#{user.email.presence || '(未設定)'})"

    print "\n新しいパスワードを入力してください (6文字以上): "
    password = STDIN.noecho(&:gets).chomp
    puts ""

    if password.length < 6
      puts "✗ パスワードは6文字以上で入力してください。"
      exit 1
    end

    print "パスワードを再入力してください: "
    password_confirmation = STDIN.noecho(&:gets).chomp
    puts ""

    if password != password_confirmation
      puts "✗ パスワードが一致しません。"
      exit 1
    end

    user.password = password
    user.password_confirmation = password_confirmation

    if user.save
      puts "\n✓ パスワードを変更しました。"
    else
      puts "\n✗ パスワード変更に失敗しました:"
      user.errors.full_messages.each do |message|
        puts "  - #{message}"
      end
      exit 1
    end
  end
end

