class Lead < ApplicationRecord
  LEAD_TYPES = %w[whatsapp_click quote_request phone_call].freeze

  belongs_to :business
  belongs_to :product, optional: true
  belongs_to :service, optional: true

  validates :lead_type, presence: true, inclusion: { in: LEAD_TYPES }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(lead_type: type) }
  scope :whatsapp_clicks, -> { where(lead_type: "whatsapp_click") }
  scope :quote_requests, -> { where(lead_type: "quote_request") }

  def target_item_name
    product&.name || service&.name || "Estabelecimento"
  end
end
