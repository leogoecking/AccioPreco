class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @categories = Category.active.order(:name)
    @featured_products = Product.available.featured.recent.limit(6).includes(:business, :category)
    @featured_services = Service.active.featured.recent.limit(6).includes(:business, :category)
    @businesses = Business.active.limit(8).includes(:user)
  end

  def search
    @query = params[:q].to_s.strip
    # Preparação para a Fase 2 (Busca unificada)
    if @query.present?
      @products = Product.available.where("LOWER(name) LIKE :q OR LOWER(description) LIKE :q", q: "%#{@query.downcase}%").limit(10)
      @services = Service.active.where("LOWER(name) LIKE :q OR LOWER(description) LIKE :q", q: "%#{@query.downcase}%").limit(10)
      @businesses = Business.active.where("LOWER(name) LIKE :q OR LOWER(description) LIKE :q", q: "%#{@query.downcase}%").limit(10)
    else
      @products = Product.none
      @services = Service.none
      @businesses = Business.none
    end
  end
end
