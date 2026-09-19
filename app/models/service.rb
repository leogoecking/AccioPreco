class Service < ApplicationRecord
  include Sluggable

  belongs_to :business
  belongs_to :category
  has_many :leads, dependent: :nullify

  has_many_attached :images

  validates :name, presence: true
  validates :starting_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :home_services, -> { where(home_service: true) }
  scope :recent, -> { order(created_at: :desc) }

  def formatted_price
    return price_description if price_description.present?
    return "A partir de R$ #{'%.2f' % starting_price}".tr(".", ",") if starting_price.present?

    "Sob consulta"
  end
end
