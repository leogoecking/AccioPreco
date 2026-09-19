class Product < ApplicationRecord
  include Sluggable

  belongs_to :business
  belongs_to :category
  has_many :leads, dependent: :nullify

  has_many_attached :images

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :promotional_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :promotional_price_less_than_regular_price

  scope :available, -> { where(available: true) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }

  def current_price
    on_sale? ? promotional_price : price
  end

  def on_sale?
    promotional_price.present? && promotional_price < price
  end

  def discount_percentage
    return 0 unless on_sale?

    (((price - promotional_price) / price) * 100).round
  end

  private

  def promotional_price_less_than_regular_price
    return unless promotional_price.present? && price.present?

    if promotional_price >= price
      errors.add(:promotional_price, "deve ser menor que o preço normal")
    end
  end
end
