class BusinessesController < ApplicationController
  allow_unauthenticated_access

  def index
    @businesses = Business.active.order(:name).includes(:user)
  end

  def show
    @business = Business.active.find_by!(slug: params[:slug])
    @products = @business.products.available.recent
    @services = @business.services.active.recent
  end
end
