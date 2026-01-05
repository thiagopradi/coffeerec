class User < ApplicationRecord
  has_one :taste_profile, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
