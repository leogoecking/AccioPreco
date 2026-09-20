class ProductsController < ApplicationController
  allow_unauthenticated_access

  def index
    @pagy, @products = pagy(Product.publicly_visible.recent.includes(:business, :category, images_attachments: :blob), limit: 12)
    @categories = Category.active.for_products
  end

  def show
    @product = Product.publicly_visible.find_by!(slug: params[:slug])
    @business = @product.business
    @related_products = @business.products.available.where.not(id: @product.id).limit(4)
  end
end
