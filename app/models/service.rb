class Service < ApplicationRecord
  include Sluggable

  belongs_to :business
  belongs_to :category
  has_many :leads, dependent: :nullify

  has_many_attached :images

  validates :name, presence: true, length: { maximum: 150 }
  validates :description, length: { maximum: 3000 }, allow_blank: true
  validates :starting_price, numericality: { greater_than: 0, less_than: 100_000_000 }, allow_nil: true
  validate :validate_images
  validate :category_must_be_for_services

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :home_services, -> { where(home_service: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :publicly_visible, -> { active.joins(:business).where(businesses: { active: true }) }
  scope :search_by_text, ->(query) {
    return all if query.blank?

    clean = sanitize_sql_like(query.to_s.strip)
    where("unaccent(services.name) ILIKE unaccent(?) OR unaccent(coalesce(services.description, '')) ILIKE unaccent(?)", "%#{clean}%", "%#{clean}%")
  }

  def self.sanitize_currency(val)
    return nil if val.blank?
    return val if val.is_a?(Numeric)

    str = val.to_s.strip.gsub(/[^\d,.-]/, "")
    return nil if str.blank?

    if str.include?(",") && str.include?(".")
      comma_idx = str.rindex(",")
      dot_idx = str.rindex(".")
      if comma_idx > dot_idx
        str = str.tr(".", "").tr(",", ".")
      else
        str = str.tr(",", "")
      end
    elsif str.include?(",")
      if str.count(",") > 1 || str =~ /\A\d{1,3}(,\d{3})+\z/
        str = str.tr(",", "")
      else
        str = str.tr(",", ".")
      end
    elsif str.include?(".")
      if str.count(".") > 1 || str =~ /\A\d{1,3}(\.\d{3})+\z/
        str = str.tr(".", "")
      end
    end

    BigDecimal(str) rescue nil
  end

  def starting_price=(val)
    super(self.class.sanitize_currency(val))
  end

  def formatted_price
    return price_description if price_description.present?
    return "A partir de R$ #{'%.2f' % starting_price}".tr(".", ",") if starting_price.present? && starting_price > 0

    "Sob consulta"
  end

  private

  def validate_images
    return unless images.attached?

    images.each do |image|
      if image.blob.byte_size > 5.megabytes
        errors.add(:images, "devem ter no máximo 5MB cada")
      end

      acceptable_types = %w[image/jpeg image/png image/webp]
      unless acceptable_types.include?(image.blob.content_type)
        errors.add(:images, "devem ser imagens no formato JPEG, PNG ou WebP")
      end
    end
  end

  def category_must_be_for_services
    return unless category

    unless category.active?
      errors.add(:category, "selecionada não está ativa")
    end

    unless category.for_services?
      errors.add(:category, "deve ser uma categoria de serviços")
    end
  end
end
