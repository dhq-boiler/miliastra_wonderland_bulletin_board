module ApplicationHelper
  # 利用可能な言語の一覧を取得
  def available_locales
    I18n.available_locales.map do |locale|
      [t("languages.#{locale}"), locale]
    end
  end

  # 現在の言語名を取得
  def current_locale_name
    t("languages.#{I18n.locale}")
  end

  # 言語切り替えリンクを生成
  def locale_link(locale, options = {})
    locale_name = t("languages.#{locale}")
    link_to locale_name, url_for(locale: locale), options
  end

  # エラー数の翻訳
  def errors_count_message(count)
    t('app.stages.errors.count', count: count) + t('app.stages.errors.has_errors')
  end

  # 難易度セレクトオプション
  def difficulty_options
    [
      [t('app.stages.form.difficulty_placeholder'), ""],
      [t('app.stages.form.difficulty_easy'), t('app.stages.form.difficulty_easy')],
      [t('app.stages.form.difficulty_normal'), t('app.stages.form.difficulty_normal')],
      [t('app.stages.form.difficulty_hard'), t('app.stages.form.difficulty_hard')],
      [t('app.stages.form.difficulty_very_hard'), t('app.stages.form.difficulty_very_hard')]
    ]
  end

  # 募集状態セレクトオプション
  def status_options
    [
      [t('app.multiplay.form.status_recruiting'), t('app.multiplay.form.status_recruiting')],
      [t('app.multiplay.form.status_closed'), t('app.multiplay.form.status_closed')]
    ]
  end
end
