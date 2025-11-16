ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# OmniAuthのテストモードを有効化
OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all  # Disabled to avoid fixture issues in system tests

    # Add more helper methods to be used by all tests here...

    # ログインヘルパーメソッド
    def log_in_as(user)
      post login_url, params: { session: { email: user.email, password: "password123" } }
    end

    def logged_in?
      !session[:user_id].nil?
    end
  end
end
