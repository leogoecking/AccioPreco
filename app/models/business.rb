class Business < ApplicationRecord
  include Sluggable

  BUSINESS_TYPES = %w[store service_provider both].freeze

  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :leads, dependent: :destroy

  has_one_attached :logo
  has_one_attached :banner

  validates :name, presence: true
  validates :business_type, presence: true, inclusion: { in: BUSINESS_TYPES }
  validates :city, presence: true
  validates :state, presence: true
  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :active, -> { where(active: true) }
  scope :verified, -> { where(verified: true) }
  scope :stores, -> { where(business_type: %w[store both]) }
  scope :service_providers, -> { where(business_type: %w[service_provider both]) }
  scope :by_city, ->(city) { where("LOWER(city) = ?", city.to_s.downcase) }

  def store?
    business_type.in?(%w[store both])
  end

  def service_provider?
    business_type.in?(%w[service_provider both])
  end

  def full_address
    parts = []
    parts << [address, number].compact_blank.join(", ") if address.present?
    parts << neighborhood if neighborhood.present?
    parts << "#{city} - #{state}" if city.present?
    parts << "CEP: #{postal_code}" if postal_code.present?
    parts.join(" · ")
  end

  def whatsapp_cleaned
    whatsapp.to_s.gsub(/\D/, "")
  end

  def whatsapp_url(text: nil)
    num = whatsapp_cleaned
    return nil if num.blank?

    num = "55#{num}" unless num.start_with?("55")
    params = text.present? ? "?text=#{CGI.escape(text)}" : ""
    "https://wa.me/#{num}#{params}"
  end
end
