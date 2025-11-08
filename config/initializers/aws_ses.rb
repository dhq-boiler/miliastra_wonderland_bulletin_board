# frozen_string_literal: true

# AWS SES configuration for ActionMailer
# This initializer configures AWS SES for email delivery in production

if Rails.env.production? && ENV['AWS_ACCESS_KEY_ID'].present?
  require 'aws-sdk-ses'

  # Configure AWS credentials
  Aws.config.update({
    region: ENV.fetch('AWS_REGION', 'ap-northeast-1'),
    credentials: Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )
  })

  # Register AWS SES delivery method
  ActionMailer::Base.add_delivery_method :aws_sdk, Aws::SES::MessageDelivery,
    region: ENV.fetch('AWS_REGION', 'ap-northeast-1')
end

