class ProductsController < ApplicationController
  allow_unauthenticated_access

  def index
    @products = Product.available.recent.includes(:business, :category)
    @categories = Category.active.for_products
  end

  def show
    @product = Product.available.find_by!(slug: params[:slug])
    @business = @product.business
    @related_products = @business.products.available.where.not(id: @product.id).limit(4)
  end
end
