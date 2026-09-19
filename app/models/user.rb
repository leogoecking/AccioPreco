class User < ApplicationRecord
  has_secure_password

  ROLES = %w[admin merchant].freeze

  alias_attribute :email, :email_address

  has_many :sessions, dependent: :destroy
  has_many :businesses, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def merchant?
    role == "merchant"
  end
end
