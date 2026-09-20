class ServicesController < ApplicationController
  allow_unauthenticated_access

  def index
    @pagy, @services = pagy(Service.publicly_visible.recent.includes(:business, :category, images_attachments: :blob), limit: 12)
    @categories = Category.active.for_services
  end

  def show
    @service = Service.publicly_visible.find_by!(slug: params[:slug])
    @business = @service.business
    @related_services = @business.services.active.where.not(id: @service.id).limit(4)
  end
end
