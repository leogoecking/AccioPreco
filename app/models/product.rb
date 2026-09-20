class Product < ApplicationRecord
  include Sluggable

  belongs_to :business
  belongs_to :category
  has_many :leads, dependent: :nullify

  has_many_attached :images

  validates :name, presence: true, length: { maximum: 150 }
  validates :description, length: { maximum: 3000 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 100_000_000 }
  validates :promotional_price, numericality: { greater_than: 0, less_than: 100_000_000 }, allow_nil: true
  validate :promotional_price_less_than_regular_price
  validate :validate_images
  validate :category_must_be_for_products

  scope :available, -> { where(available: true) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :publicly_visible, -> { available.joins(:business).where(businesses: { active: true }) }
  scope :search_by_text, ->(query) {
    return all if query.blank?

    clean = sanitize_sql_like(query.to_s.strip)
    where("unaccent(products.name) ILIKE unaccent(?) OR unaccent(coalesce(products.description, '')) ILIKE unaccent(?)", "%#{clean}%", "%#{clean}%")
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

  def price=(val)
    super(self.class.sanitize_currency(val))
  end

  def promotional_price=(val)
    super(self.class.sanitize_currency(val))
  end

  def current_price
    on_sale? ? promotional_price : price
  end

  def on_sale?
    promotional_price.present? && promotional_price < price
  end

  def discount_percentage
    return 0 unless on_sale? && price.to_f > 0

    (((price - promotional_price) / price) * 100).round
  end

  private

  def promotional_price_less_than_regular_price
    return unless promotional_price.present? && price.present?

    if promotional_price >= price
      errors.add(:promotional_price, "deve ser menor que o preço normal")
    end
  end

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

  def category_must_be_for_products
    return unless category

    unless category.active?
      errors.add(:category, "selecionada não está ativa")
    end

    unless category.for_products?
      errors.add(:category, "deve ser uma categoria de produtos")
    end
  end
end
