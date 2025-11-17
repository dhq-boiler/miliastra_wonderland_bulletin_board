# frozen_string_literal: true

require "rails_image_post_solution"

RailsImagePostSolution.configure do |config|
  # OpenAI API key (recommended to use environment variable)
  config.openai_api_key = ENV["OPENAI_API_KEY"]

  # Auto-freeze posts when inappropriate content is detected
  # Default: true
  config.auto_freeze_on_flag = true

  # Method name to check admin permissions
  # Specify method name to be called on current_user
  # Default: :admin?
  config.admin_check_method = :admin?
end
