class Category < ApplicationRecord
  include Sluggable

  CATEGORY_TYPES = %w[product service both].freeze

  has_many :products, dependent: :restrict_with_error
  has_many :services, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :category_type, presence: true, inclusion: { in: CATEGORY_TYPES }

  scope :active, -> { where(active: true) }
  scope :for_products, -> { where(category_type: %w[product both]) }
  scope :for_services, -> { where(category_type: %w[service both]) }

  def for_products?
    category_type.in?(%w[product both])
  end

  def for_services?
    category_type.in?(%w[service both])
  end
end
