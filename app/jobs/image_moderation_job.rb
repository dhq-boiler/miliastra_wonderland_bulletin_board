class ImageModerationJob < ApplicationJob
  queue_as :default

  # 画像の自動モデレーションを実行するジョブ
  # OpenAI Vision APIを使用してR18/R18Gコンテンツを検出
  def perform(attachment_id)
    attachment = ActiveStorage::Attachment.find_by(id: attachment_id)
    return unless attachment&.blob

    # OpenAI Vision Serviceを使用して画像を分析
    result = OpenaiVisionService.new.moderate_image(attachment)

    # 結果を処理
    if result[:flagged]
      # 不適切なコンテンツが検出された場合、自動的に通報を作成
      create_auto_report(attachment, result)

      # 投稿を仮凍結
      freeze_post(attachment, result)
    end

    Rails.logger.info "Image moderation completed for attachment ##{attachment_id}: #{result[:flagged] ? 'FLAGGED' : 'OK'}"
  rescue StandardError => e
    Rails.logger.error "Image moderation failed for attachment ##{attachment_id}: #{e.message}"
    # エラーが発生してもジョブは失敗させない（手動レビューに委ねる）
  end

  private

  def create_auto_report(attachment, result)
    # システムユーザーまたはnilユーザーとして自動通報を作成
    # 既に自動通報がある場合はスキップ
    existing_report = ImageReport.find_by(
      active_storage_attachment_id: attachment.id,
      user_id: nil # システムによる自動通報
    )

    return if existing_report

    ImageReport.create!(
      active_storage_attachment: attachment,
      user_id: nil, # システムによる自動通報
      reason: build_auto_report_reason(result),
      status: ImageReport::STATUSES[:confirmed], # 自動的に確認済み（不適切）にする
      reviewed_at: Time.current,
      ai_flagged: result[:flagged],
      ai_confidence: result[:confidence],
      ai_categories: result[:categories].to_json,
      ai_detected_at: Time.current
    )
  end

  def build_auto_report_reason(result)
    reasons = []
    reasons << "🤖 自動検出: 不適切なコンテンツが検出されました"

    if result[:categories]
      flagged_categories = result[:categories].select { |_, flagged| flagged }
      if flagged_categories.any?
        reasons << "\n検出されたカテゴリ:"
        flagged_categories.each do |category, _|
          reasons << "  - #{category}"
        end
      end
    end

    if result[:confidence]
      reasons << "\n信頼度: #{(result[:confidence] * 100).round(1)}%"
    end

    reasons.join("\n")
  end

  # 投稿を仮凍結
  def freeze_post(attachment, result)
    record = attachment.record
    return unless record

    # StageまたはMultiplayRecruitmentCommentの場合のみ凍結
    return unless record.is_a?(Stage) || record.is_a?(MultiplayRecruitmentComment)

    # 既に凍結されている場合はスキップ
    return if record.frozen?

    reason = "🤖 AI自動判定: 不適切なコンテンツが検出されたため、仮凍結されました。\n#{build_auto_report_reason(result)}"

    record.freeze_post!(type: :temporary, reason: reason)
    Rails.logger.info "Post #{record.class.name}##{record.id} has been temporarily frozen due to inappropriate content"
  rescue StandardError => e
    Rails.logger.error "Failed to freeze post for attachment ##{attachment.id}: #{e.message}"
  end
end
