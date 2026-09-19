module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, on: [:create, :update]
    validates :slug, presence: true
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present? && !name_changed?

    source_text = send(slug_source_attribute).to_s.strip
    return if source_text.blank?

    base_slug = source_text.parameterize
    return if base_slug.blank?

    candidate = base_slug
    counter = 1

    scope = slug_uniqueness_scope

    while scope.exists?(slug: candidate)
      counter += 1
      candidate = "#{base_slug}-#{counter}"
    end

    self.slug = candidate
  end

  def slug_source_attribute
    :name
  end

  def slug_uniqueness_scope
    scope = self.class.all
    scope = scope.where.not(id: id) if persisted?
    scope
  end
end
