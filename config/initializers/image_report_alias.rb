# frozen_string_literal: true

# Create an alias so that RailsImagePostSolution::ImageReport points to the main app's ImageReport model
# This allows the gem's admin views to work with the main app's model
Rails.application.config.to_prepare do
  RailsImagePostSolution::ImageReport = ImageReport unless defined?(RailsImagePostSolution::ImageReport)
end
