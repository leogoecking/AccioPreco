module Painel
  class ProductsController < BaseController
    before_action :require_business!
    before_action :set_product, only: %i[show edit update destroy]

    def index
      @products = @current_business.products.recent
    end

    def show
    end

    def new
      @product = @current_business.products.build
      @categories = Category.active.for_products
    end

    def create
      @product = @current_business.products.build(product_params)
      if @product.save
        redirect_to painel_products_path, notice: "Produto cadastrado com sucesso!"
      else
        @categories = Category.active.for_products
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.active.for_products
    end

    def update
      if @product.update(product_params)
        redirect_to painel_products_path, notice: "Produto atualizado com sucesso!"
      else
        @categories = Category.active.for_products
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to painel_products_path, notice: "Produto excluído com sucesso!"
    end

    private

    def set_product
      @product = @current_business.products.find_by(slug: params[:id]) ||
                 @current_business.products.find_by!(id: params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :category_id, :description, :price, :promotional_price, :available, :featured, images: [])
    end
  end
end
