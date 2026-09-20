class BusinessesController < ApplicationController
  allow_unauthenticated_access

  def index
    @pagy, @businesses = pagy(Business.active.order(:name).includes(:user, logo_attachment: :blob), limit: 12)
  end

  def show
    @business = Business.active.includes(logo_attachment: :blob, banner_attachment: :blob).find_by!(slug: params[:slug])
    @products = @business.products.available.recent.includes(:category, images_attachments: :blob)
    @services = @business.services.active.recent.includes(:category, images_attachments: :blob)
  end
end
