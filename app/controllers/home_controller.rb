class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @categories = Category.active.order(:name)
    @featured_products = Product.publicly_visible.featured.recent.limit(6).includes(business: { logo_attachment: :blob }, category: {}, images_attachments: :blob)
    @featured_services = Service.publicly_visible.featured.recent.limit(6).includes(business: { logo_attachment: :blob }, category: {}, images_attachments: :blob)
    @businesses = Business.active.limit(8).includes(:user, logo_attachment: :blob)
  end
end
