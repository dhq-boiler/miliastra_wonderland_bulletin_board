class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale

  helper_method :current_user, :logged_in?

  private
    def set_locale
      # 優先順位: URLパラメータ > ユーザー設定 > Accept-Languageヘッダー > デフォルト
      I18n.locale = locale_from_params ||
                    locale_from_user ||
                    locale_from_header ||
                    I18n.default_locale
    end

    def locale_from_params
      params[:locale] if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
    end

    def locale_from_user
      current_user&.locale if current_user&.locale.present? && I18n.available_locales.include?(current_user.locale.to_sym)
    end

    def locale_from_header
      return nil unless request.env['HTTP_ACCEPT_LANGUAGE']

      accepted = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/([a-z]{2}(?:-[A-Z]{2})?)(?:;q=([0-9.]+))?/).map do |lang, quality|
        [lang, (quality || 1.0).to_f]
      end.sort_by { |_, quality| -quality }

      accepted.each do |lang, _|
        # 完全一致を優先
        return lang if I18n.available_locales.include?(lang.to_sym)
        # 言語コードのみの一致（例: zh-CN -> zh）
        base_lang = lang.split('-').first
        matched = I18n.available_locales.find { |l| l.to_s.start_with?(base_lang) }
        return matched.to_s if matched
      end
      nil
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def logged_in?
      current_user.present?
    end

    def require_login
      unless logged_in?
        redirect_to login_path, alert: I18n.t('errors.messages.login_required')
      end
    end

    def default_url_options
      { locale: I18n.locale }
    end
end
