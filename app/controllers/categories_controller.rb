class CategoriesController < ApplicationController
  allow_unauthenticated_access

  def show
    @category = Category.active.find_by!(slug: params[:slug])
    @categories = Category.active.order(:name)
    @products_count = @category.products.publicly_visible.count
    @services_count = @category.services.publicly_visible.count

    @type = params[:type].presence || determine_default_type

    case @type
    when "produtos"
      @pagy, @products = pagy(@category.products.publicly_visible.recent.includes(:business, images_attachments: :blob), limit: 12)
      @services = Service.none
    when "servicos"
      @pagy, @services = pagy(@category.services.publicly_visible.recent.includes(:business, images_attachments: :blob), limit: 12)
      @products = Product.none
    else # "todos"
      @products = @category.products.publicly_visible.recent.includes(:business, images_attachments: :blob).limit(8)
      @services = @category.services.publicly_visible.recent.includes(:business, images_attachments: :blob).limit(8)
      @pagy = nil
    end
  end

  private

  def determine_default_type
    if @products_count > 0 && @services_count > 0
      "todos"
    elsif @products_count > 0
      "produtos"
    else
      "servicos"
    end
  end
end
