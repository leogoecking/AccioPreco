class Business < ApplicationRecord
  include Sluggable

  BUSINESS_TYPES = %w[store service_provider both].freeze

  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :leads, dependent: :destroy

  has_one_attached :logo
  has_one_attached :banner

  validates :name, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :business_type, presence: true, inclusion: { in: BUSINESS_TYPES }
  validates :city, presence: true
  validates :state, presence: true
  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_attachments
  validate :validate_whatsapp

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
    digits = whatsapp.to_s.gsub(/\D/, "").sub(/^0+/, "")
    digits = "55#{digits}" if digits.length.in?([10, 11])
    digits if digits.length.in?([12, 13])
  end

  def whatsapp_url(text: nil)
    num = whatsapp_cleaned
    return nil if num.blank?

    params = text.present? ? "?text=#{CGI.escape(text)}" : ""
    "https://wa.me/#{num}#{params}"
  end

  def instagram_handle
    return nil if instagram.blank?

    handle = instagram.to_s.strip
    handle = handle.sub(%r{\Ahttps?://(www\.)?instagram\.com/}, "")
    handle = handle.delete_prefix("@").chomp("/")
    handle.presence
  end

  def instagram_url
    handle = instagram_handle
    return nil if handle.blank?

    "https://instagram.com/#{handle}"
  end

  def profile_completion_status
    steps = [
      {
        id: :name,
        label: "Nome da empresa",
        description: "Identificação principal do negócio",
        completed: name.present?,
        weight: 15
      },
      {
        id: :whatsapp,
        label: "WhatsApp para atendimento",
        description: "Canal direto para receber contatos de clientes",
        completed: whatsapp.present? && whatsapp_cleaned.present?,
        weight: 20
      },
      {
        id: :address,
        label: "Endereço e bairro",
        description: "Ajuda os clientes locais a encontrarem sua loja física",
        completed: address.present? && neighborhood.present?,
        weight: 15
      },
      {
        id: :description,
        label: "Descrição do estabelecimento",
        description: "Apresente especialidades, horários e diferenciais",
        completed: description.present? && description.strip.length >= 20,
        weight: 15
      },
      {
        id: :logo,
        label: "Logotipo ou foto de perfil",
        description: "Transmite confiança e reconhecimento visual",
        completed: logo.attached?,
        weight: 15
      },
      {
        id: :catalog,
        label: "Primeiro produto ou serviço",
        description: "Essencial para aparecer nas pesquisas locais",
        completed: products.exists? || services.exists?,
        weight: 15
      },
      {
        id: :contact_extra,
        label: "Instagram ou telefone adicional",
        description: "Canais complementares para contato e credibilidade",
        completed: instagram.present? || phone.present?,
        weight: 5
      }
    ]

    total_completed = steps.select { |s| s[:completed] }.sum { |s| s[:weight] }
    {
      percentage: [total_completed, 100].min,
      steps: steps,
      missing_steps: steps.reject { |s| s[:completed] }
    }
  end

  def profile_completion_percentage
    profile_completion_status[:percentage]
  end

  private

  def validate_attachments
    if logo.attached?
      errors.add(:logo, "deve ter no máximo 3MB") if logo.blob.byte_size > 3.megabytes
      errors.add(:logo, "deve ser uma imagem válida (JPEG, PNG ou WebP)") unless logo.blob.content_type.in?(%w[image/jpeg image/png image/webp])
    end

    if banner.attached?
      errors.add(:banner, "deve ter no máximo 5MB") if banner.blob.byte_size > 5.megabytes
      errors.add(:banner, "deve ser uma imagem válida (JPEG, PNG ou WebP)") unless banner.blob.content_type.in?(%w[image/jpeg image/png image/webp])
    end
  end

  def validate_whatsapp
    return if whatsapp.blank?

    if whatsapp_cleaned.blank?
      errors.add(:whatsapp, "deve ser um número de WhatsApp válido com DDD (ex: 73999998888)")
    end
  end
end
