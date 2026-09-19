class ServicesController < ApplicationController
  allow_unauthenticated_access

  def index
    @services = Service.active.recent.includes(:business, :category)
    @categories = Category.active.for_services
  end

  def show
    @service = Service.active.find_by!(slug: params[:slug])
    @business = @service.business
    @related_services = @business.services.active.where.not(id: @service.id).limit(4)
  end
end
