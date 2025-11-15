# PostgreSQL データベースバックアップ

このドキュメントでは、PostgreSQLデータベースのバックアップとリストアの方法について説明します。

## 概要

- **バックアップ方式**: pg_dump (論理バックアップ)
- **保存先**: AWS S3
- **自動実行**: cron (毎日深夜3時)
- **保持期間**: 30日間（設定可能）
- **圧縮**: gzip (圧縮率9)

## セットアップ

### 1. S3バケットの作成

AWS マネジメントコンソールで S3 バケットを作成：

```bash
# AWS CLI で作成する場合
aws s3 mb s3://miliastra-wonderland-backups --region ap-northeast-1

# ライフサイクルポリシーの設定（オプション）
# 90日後に Glacier に移行、1年後に削除
```

### 2. IAM ポリシーの設定

EC2 インスタンスに以下の権限を持つ IAM ロールをアタッチ：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::miliastra-wonderland-backups",
        "arn:aws:s3:::miliastra-wonderland-backups/*"
      ]
    }
  ]
}
```

### 3. 環境変数の設定

`.kamal/secrets` ファイルに以下を追加：

```bash
# AWS認証情報（IAMロールを使う場合は不要）
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key

# PostgreSQLパスワード
DB_PASSWORD=your_database_password
```

`config/deploy.yml` で以下が設定されていることを確認：

```yaml
env:
  clear:
    BACKUP_S3_BUCKET: miliastra-wonderland-backups
    BACKUP_S3_PREFIX: database
    BACKUP_RETENTION_DAYS: 30
```

## バックアップの実行

### 自動バックアップ

毎日深夜3時に自動的にバックアップが実行されます（`config/schedule.rb` で設定）。

ログは `/rails/log/backup.log` に出力されます。

### 手動バックアップ

本番環境で手動でバックアップを実行する場合：

```bash
# Kamalでコンテナに接続して実行
kamal app exec -i "/rails/bin/backup_database"

# または、SSH接続して直接実行
ssh ec2-user@your-server
docker exec -it miliastra_wonderland_bulletin_board-web-1 /rails/bin/backup_database
```

## バックアップの確認

S3に保存されたバックアップを確認：

```bash
# ローカルから確認
aws s3 ls s3://miliastra-wonderland-backups/database/

# 出力例：
# 2025-11-15 03:00:01     123456789 miliastra_wonderland_db_20251115_030000.sql.gz
# 2025-11-14 03:00:01     123456790 miliastra_wonderland_db_20251114_030000.sql.gz
```

## データベースのリストア

### 前提条件

⚠️ **警告**: リストアすると既存のデータベースが削除されます！

### リストア手順

1. **利用可能なバックアップを確認**:

```bash
kamal app exec -i "/rails/bin/restore_database"
# 引数なしで実行すると、利用可能なバックアップ一覧が表示されます
```

2. **リストアの実行**:

```bash
# 特定のバックアップからリストア
kamal app exec -i "/rails/bin/restore_database miliastra_wonderland_db_20251115_030000.sql.gz"

# 確認プロンプトが表示されます
# WARNING: This will DROP the existing database and restore from backup. Continue? (yes/no):
# "yes" と入力して Enter
```

3. **アプリケーションの再起動**:

```bash
kamal app restart
```

## バックアップファイルの構造

```
s3://miliastra-wonderland-backups/
└── database/
    ├── miliastra_wonderland_db_20251115_030000.sql.gz
    ├── miliastra_wonderland_db_20251114_030000.sql.gz
    ├── miliastra_wonderland_db_20251113_030000.sql.gz
    └── ...
```

- **ファイル名形式**: `miliastra_wonderland_db_YYYYMMDD_HHMMSS.sql.gz`
- **圧縮形式**: gzip
- **バックアップ形式**: PostgreSQL custom format (pg_dump -Fc)

## トラブルシューティング

### バックアップが失敗する

1. **ログを確認**:
   ```bash
   kamal app logs | grep backup
   # または
   kamal app exec -i "cat /rails/log/backup.log"
   ```

2. **S3への接続確認**:
   ```bash
   kamal app exec -i "aws s3 ls s3://miliastra-wonderland-backups/"
   ```

3. **PostgreSQL接続確認**:
   ```bash
   kamal app exec -i "pg_dump --version"
   kamal app exec -i "PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -U \$DB_USERNAME -d \$DB_NAME -c 'SELECT version();'"
   ```

### リストアが失敗する

1. **バックアップファイルの整合性確認**:
   ```bash
   aws s3 cp s3://miliastra-wonderland-backups/database/miliastra_wonderland_db_20251115_030000.sql.gz - | gunzip | head
   ```

2. **ディスク容量確認**:
   ```bash
   kamal app exec -i "df -h"
   ```

## 設定のカスタマイズ

### バックアップ時間の変更

`config/schedule.rb` を編集：

```ruby
# 毎日深夜2時に変更
every 1.day, at: '2:00 am' do
  command "/rails/bin/backup_database >> /rails/log/backup.log 2>&1"
end
```

### 保持期間の変更

`config/deploy.yml` を編集：

```yaml
env:
  clear:
    BACKUP_RETENTION_DAYS: 60  # 60日間保持
```

### バックアップ頻度の変更

`config/schedule.rb` で頻度を変更：

```ruby
# 12時間ごと
every 12.hours do
  command "/rails/bin/backup_database >> /rails/log/backup.log 2>&1"
end
```

## セキュリティのベストプラクティス

1. **IAM ロールの使用**: EC2インスタンスにIAMロールをアタッチし、アクセスキーの使用を避ける
2. **S3バケットの暗号化**: サーバーサイド暗号化（SSE-S3 または SSE-KMS）を有効化
3. **バケットポリシーの設定**: 最小権限の原則に従う
4. **バージョニングの有効化**: S3バケットでバージョニングを有効化し、誤削除を防ぐ

## コスト見積もり

バックアップのコスト例（1ファイル100MBと仮定）：

- **S3 Standard-IA ストレージ**: $0.0125/GB/月
- **30日分のバックアップ**: 100MB × 30 = 3GB
- **月額コスト**: 約 $0.0375/月

実際のコストは、データベースサイズによって変動します。
