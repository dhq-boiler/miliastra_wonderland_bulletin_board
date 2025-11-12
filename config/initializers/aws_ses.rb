# frozen_string_literal: true

# AWS SES configuration for ActionMailer
# This initializer configures AWS SES for email delivery in production

if Rails.env.production? && ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_SECRET_ACCESS_KEY"].present?
  begin
    require "aws-sdk-ses"

    # Custom delivery class for AWS SES
    class AwsSesDelivery
      attr_accessor :settings

      def initialize(settings)
        @settings = settings
      end

      def deliver!(mail)
        ses_client = Aws::SES::Client.new(
          region: @settings[:region] || ENV.fetch("AWS_REGION", "ap-northeast-1"),
          credentials: Aws::Credentials.new(
            ENV["AWS_ACCESS_KEY_ID"],
            ENV["AWS_SECRET_ACCESS_KEY"]
          )
        )

        ses_client.send_raw_email(
          raw_message: {
            data: mail.to_s
          }
        )
      end
    end

    # Register custom AWS SES delivery method
    ActionMailer::Base.add_delivery_method :aws_ses, AwsSesDelivery,
      region: ENV.fetch("AWS_REGION", "ap-northeast-1")
  rescue LoadError => e
    Rails.logger.warn "AWS SES not available: #{e.message}"
  end
end
