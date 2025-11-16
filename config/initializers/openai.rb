# OpenAI API Configuration
# 画像の自動モデレーション機能で使用

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY", nil)
end
