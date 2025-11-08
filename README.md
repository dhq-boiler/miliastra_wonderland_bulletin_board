# Miliastra Wonderland 掲示板

ゲーム「Miliastra Wonderland」のための掲示板アプリケーションです。
幻境（ステージ）の攻略情報を共有したり、マルチプレイの同行者を募集できます。

**公式サイト**: https://miliastra-wonderland-bulletin-board.com

## 機能

### 実装済み
- **ステージ紹介投稿機能**
  - ステージの詳細情報（タイトル、ステージ番号、GUID、難易度、説明、攻略のコツ）を投稿
  - 投稿の閲覧、編集、削除
  - 投稿者による編集・削除の権限管理

- **ユーザー認証機能**
  - ユーザー登録
  - ログイン/ログアウト
  - セッション管理

### 今後実装予定
- マルチプレイ同行者募集機能

## セットアップ

### 必要な環境
- Ruby 3.4.7
- Rails 8.1.1
- SQLite3（開発・テスト環境）
- PostgreSQL 16（本番環境 - Dockerコンテナで自動セットアップ）

### インストール手順

1. リポジトリをクローン
```bash
git clone [repository-url]
cd miliastra_wonderland_bulletin_board
```

2. 依存パッケージをインストール
```bash
bundle install
```

3. 環境変数の設定（必要に応じて）
```bash
# .env.exampleをコピーして.envファイルを作成
cp .env.example .env

# .envファイルを編集して必要な環境変数を設定
# 開発環境では通常は編集不要です
```

4. データベースのセットアップ
```bash
bin/rails db:migrate
bin/rails db:seed  # サンプルデータを作成（任意）
```

5. サーバーを起動
```bash
bin/rails server
```

6. ブラウザで http://localhost:3000 にアクセス

## 使い方

### 新規登録
1. トップページの「新規登録」ボタンをクリック
2. ユーザー名、メールアドレス、パスワードを入力
3. 「登録」ボタンをクリック

### ステージ紹介の投稿
1. ログイン後、「新しいステージ紹介を投稿」ボタンをクリック
2. 以下の情報を入力：
   - タイトル：投稿のタイトル
   - ステージ番号：ステージの識別番号（例：1-1）
   - ステージGUID：ゲーム内のステージGUID（整数）
   - 難易度：簡単/普通/難しい/とても難しい（任意）
   - ステージの説明：ステージの特徴や注意点
   - 攻略のコツ：クリアのヒントやおすすめの戦略（任意）
3. 「Create Stage」ボタンをクリックして投稿

### ステージ紹介の閲覧
- トップページに投稿一覧が表示されます
- タイトルをクリックすると詳細ページが開きます
- ログインしていなくても閲覧可能です

### ステージ紹介の編集・削除
- 自分が投稿したステージ紹介の詳細ページに「編集」「削除」ボタンが表示されます
- 他のユーザーの投稿は編集・削除できません

## サンプルアカウント

`bin/rails db:seed` を実行すると、以下のサンプルアカウントが作成されます：

- ユーザー名: `admin` / パスワード: `password`
- ユーザー名: `player1` / パスワード: `password`

## 技術スタック

- **フレームワーク**: Ruby on Rails 8.1.1
- **データベース**: 
  - 開発・テスト: SQLite3
  - 本番: PostgreSQL 16
- **認証**: bcrypt (has_secure_password)
- **フロントエンド**: Turbo, Stimulus
- **スタイル**: カスタムCSS
- **デプロイ**: Kamal
- **コンテナ**: Docker
- **SSL**: Let's Encrypt

## 本番環境デプロイ

### 前提条件
- サーバー: AWS EC2インスタンス
- ドメイン: miliastra-wonderland-bulletin-board.com
- データベース: PostgreSQL 16（Dockerコンテナ）

### 初回デプロイ手順

#### 1. 環境変数の設定
```bash
# .envファイルを作成（開発環境で既に作成している場合はスキップ）
cp .env.example .env

# .envファイルを編集して本番環境の情報を設定
# vim .env
```

#### 2. デプロイ設定
```bash
# config/deploy.ymlを編集して以下を設定
# - servers.web: サーバーのIPアドレス
# - accessories.db.host: サーバーのIPアドレス
# - ssh.keys: SSH鍵のパス
```

#### 3. DNS設定
ドメインのDNS設定でAレコードを追加してください。

#### 4. シークレットファイルの作成
```bash
# .envファイルに必要な環境変数を設定
# RAILS_MASTER_KEY: config/master.keyの内容
cat config/master.key  # この値をコピー

# POSTGRES_PASSWORD: 強力なパスワードを生成
openssl rand -base64 32  # この値をコピー

# .envファイルを編集して上記の値を設定
vim .env

# .kamal/secretsファイルを作成（.envから自動読み込み）
cp .kamal/secrets.example .kamal/secrets
chmod 600 .kamal/secrets
# .kamal/secretsは.envファイルから環境変数を読み込みます
```

#### 5. デプロイ実行
```bash
# PostgreSQLとアプリケーションをセットアップ
bin/kamal setup

# データベースの作成とマイグレーション
bin/kamal app exec 'bin/rails db:create db:migrate'

# サンプルデータの投入（任意）
bin/kamal app exec 'bin/rails db:seed'
```

#### 6. 動作確認
```bash
curl https://miliastra-wonderland-bulletin-board.com/up
```

### 通常のデプロイ（コード更新時）
```bash
bin/kamal deploy
```

### よく使うコマンド

```bash
# ログ確認
bin/kamal logs
bin/kamal logs -f  # リアルタイム監視

# Railsコンソール
bin/kamal console

# データベースバックアップ
bin/kamal accessory exec db 'pg_dump -U postgres miliastra_wonderland_bulletin_board_production' > backup.sql

# マイグレーション実行
bin/kamal app exec 'bin/rails db:migrate'

# 環境変数の更新
bin/kamal env push
bin/kamal app boot
```

## ドメイン

- **本番環境**: https://miliastra-wonderland-bulletin-board.com
- **開発環境**: http://localhost:3000

## 環境変数管理

このプロジェクトは `dotenv-rails` gemを使用して環境変数を管理しています。

### 開発環境
```bash
# .env.exampleをコピー
cp .env.example .env

# .envファイルを編集（必要に応じて）
# 開発環境では通常は設定不要です
```

### 本番環境
`.env`ファイルに以下の環境変数を設定してください：

- `RAILS_MASTER_KEY`: Rails credentialsの暗号化キー
- `POSTGRES_PASSWORD`: PostgreSQLデータベースのパスワード
- `DB_HOST`: データベースサーバーのIPアドレス
- `DB_PASSWORD`: アプリケーションからのデータベース接続パスワード

`.kamal/secrets`ファイルは`.env`から自動的に環境変数を読み込みます。

## セキュリティ注意事項

⚠️ **重要**: 以下のファイルは絶対にGitにコミットしないでください：

- `.env` - 環境変数（.gitignoreに含まれています）
- `.kamal/secrets` - デプロイ用シークレット（.gitignoreに含まれています）
- `config/master.key` - Rails暗号化キー（.gitignoreに含まれています）

✅ **コミットして良いファイル**:
- `.env.example` - 環境変数のテンプレート
- `.kamal/secrets.example` - シークレットのテンプレート

## ライセンス

...
