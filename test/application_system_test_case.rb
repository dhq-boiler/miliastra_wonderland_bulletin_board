require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # システムテストではfixturesを使わない
  self.use_transactional_tests = false

  # fixturesを無効化
  def self.fixtures(*args)
    # Do nothing - disable fixtures for system tests
  end
end
