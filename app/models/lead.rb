class Lead < ApplicationRecord
  LEAD_TYPES = %w[whatsapp_click quote_request phone_call].freeze

  belongs_to :business
  belongs_to :product, optional: true
  belongs_to :service, optional: true

  validates :lead_type, presence: true, inclusion: { in: LEAD_TYPES }
  validates :name, presence: true, length: { maximum: 100 }, if: -> { lead_type == "quote_request" }
  validates :phone, presence: true, length: { maximum: 30 }, if: -> { lead_type == "quote_request" }
  validates :message, length: { maximum: 1000 }, allow_blank: true
  validate :phone_format_for_quote_request

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(lead_type: type) }
  scope :whatsapp_clicks, -> { where(lead_type: "whatsapp_click") }
  scope :quote_requests, -> { where(lead_type: "quote_request") }

  def target_item_name
    product&.name || service&.name || "Estabelecimento"
  end

  def customer_whatsapp_url
    return nil if phone.blank?

    digits = phone.to_s.gsub(/\D/, "").sub(/^0+/, "")
    digits = "55#{digits}" if digits.length.in?([10, 11])
    return nil unless digits.length.in?([12, 13])

    client_name = name.presence || "Cliente"
    item = target_item_name
    text = "Olá #{client_name}! Vi seu contato no Accio Preço sobre '#{item}'. Como posso te ajudar?"
    "https://wa.me/#{digits}?text=#{CGI.escape(text)}"
  end

  private

  def phone_format_for_quote_request
    return unless lead_type == "quote_request" && phone.present?

    clean_digits = phone.to_s.gsub(/\D/, "").sub(/^0+/, "")
    if clean_digits.length < 10 || clean_digits.length > 13
      errors.add(:phone, "deve conter um número válido com DDD (mínimo 10 dígitos)")
    end
  end
end
