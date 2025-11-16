class OpenaiVisionService
  # OpenAI Vision APIを使用して画像のコンテンツモデレーションを実行

  def initialize
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  # 画像を分析してR18/R18Gコンテンツを検出
  # @param attachment [ActiveStorage::Attachment] 分析する画像
  # @return [Hash] 分析結果 { flagged: Boolean, categories: Hash, confidence: Float, raw_response: Hash }
  def moderate_image(attachment)
    # OpenAI APIキーが設定されていない場合はスキップ
    return safe_result unless ENV["OPENAI_API_KEY"].present?

    # 画像URLを取得（一時的なURLを生成）
    image_url = get_image_url(attachment)
    return safe_result unless image_url

    # OpenAI Vision APIを呼び出し
    response = call_vision_api(image_url)

    # レスポンスを解析
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error "OpenAI Vision API error: #{e.message}"
    safe_result # エラー時は安全側に倒す（フラグなし）
  end

  private

  def get_image_url(attachment)
    # Rails.application.routes.url_helpers.rails_blob_url(attachment, only_path: false)
    # 開発環境ではローカルURLが使えないので、Base64エンコードを使用
    return nil unless attachment.blob

    # 画像をBase64エンコード
    image_data = attachment.blob.download
    base64_image = Base64.strict_encode64(image_data)
    "data:#{attachment.blob.content_type};base64,#{base64_image}"
  rescue StandardError => e
    Rails.logger.error "Failed to get image data: #{e.message}"
    nil
  end

  def call_vision_api(image_url)
    @client.chat(
      parameters: {
        model: "gpt-4o-mini", # 画像分析が可能なモデル
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: moderation_prompt
              },
              {
                type: "image_url",
                image_url: {
                  url: image_url
                }
              }
            ]
          }
        ],
        max_tokens: 500
      }
    )
  end

  def moderation_prompt
    <<~PROMPT
      この画像を分析して、以下のカテゴリに該当するかどうかを判定してください：

      1. R18（成人向けコンテンツ）：性的な表現や裸体が含まれる
      2. R18G（グロテスクなコンテンツ）：暴力的、残酷、血まみれの表現が含まれる
      3. 違法コンテンツ：違法薬物、武器の不適切な使用など

      以下のJSON形式で回答してください：
      {
        "flagged": true/false,
        "categories": {
          "r18": true/false,
          "r18g": true/false,
          "illegal": true/false
        },
        "confidence": 0.0-1.0,
        "reason": "判定理由の簡潔な説明"
      }

      **重要**: JSON形式のみで回答し、他の文章は含めないでください。
    PROMPT
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    return safe_result unless content

    # JSONレスポンスをパース
    result = JSON.parse(content)

    {
      flagged: result["flagged"] || false,
      categories: result["categories"] || {},
      confidence: result["confidence"] || 0.0,
      reason: result["reason"],
      raw_response: response
    }
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse OpenAI response: #{e.message}, Content: #{content}"
    safe_result
  end

  def safe_result
    {
      flagged: false,
      categories: {},
      confidence: 0.0,
      reason: nil,
      raw_response: nil
    }
  end
end
