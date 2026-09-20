class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @search_service = SearchService.new(search_params)
    @results = @search_service.call

    @query = @results[:query]
    @type = @results[:type]
    @category = @results[:category]
    @categories = Category.active.order(:name)

    @products_count = @results[:counts][:products]
    @services_count = @results[:counts][:services]
    @businesses_count = @results[:counts][:businesses]
    @total_count = @results[:counts][:total]

    case @type
    when "produtos"
      @pagy, @products = pagy(@results[:products], limit: 12)
      @services = Service.none
      @businesses = Business.none
    when "servicos"
      @pagy, @services = pagy(@results[:services], limit: 12)
      @products = Product.none
      @businesses = Business.none
    when "empresas"
      @pagy, @businesses = pagy(@results[:businesses], limit: 12)
      @products = Product.none
      @services = Service.none
    else # "todos"
      @products = @results[:products].limit(6)
      @services = @results[:services].limit(6)
      @businesses = @results[:businesses].limit(4)
      @pagy = nil
    end
  end

  private

  def search_params
    params.permit(:q, :type, :category, :available, :home_service, :page)
  end
end
