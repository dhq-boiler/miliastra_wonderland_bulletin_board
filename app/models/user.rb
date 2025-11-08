class User < ApplicationRecord
  has_secure_password

  has_many :stages, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
