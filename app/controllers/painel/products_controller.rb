module Painel
  class ProductsController < BaseController
    before_action :require_business!
    before_action :set_product, only: %i[show edit update destroy toggle_availability purge_image]

    def index
      scope = @current_business.products.recent.includes(:category)
      scope = scope.search_by_text(params[:q]) if params[:q].present?
      scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?

      case params[:status]
      when "available"
        scope = scope.available
      when "unavailable"
        scope = scope.where(available: false)
      end

      @pagy, @products = pagy(scope, limit: 12)
      @categories = Category.active.for_products.order(:name)
    end

    def show
      redirect_to edit_painel_product_path(@product)
    end

    def new
      @product = @current_business.products.build(available: true)
      @categories = Category.active.for_products.order(:name)
    end

    def create
      images_to_attach = product_params[:images]&.compact_blank
      clean_params = product_params.except(:images)

      @product = @current_business.products.build(clean_params)
      @product.images.attach(images_to_attach) if images_to_attach.present?

      if @product.save
        redirect_to painel_products_path, notice: "Produto '#{@product.name}' cadastrado com sucesso!"
      else
        @categories = Category.active.for_products.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.active.for_products.order(:name)
    end

    def update
      images_to_attach = product_params[:images]&.compact_blank
      clean_params = product_params.except(:images)

      @product.assign_attributes(clean_params)
      @product.images.attach(images_to_attach) if images_to_attach.present?

      if @product.save
        redirect_to painel_products_path, notice: "Produto '#{@product.name}' atualizado com sucesso!"
      else
        @categories = Category.active.for_products.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_availability
      new_status = !@product.available
      if @product.update(available: new_status)
        respond_to do |format|
          format.turbo_stream
          format.html do
            status_msg = new_status ? "agora está disponível" : "foi marcado como indisponível"
            redirect_back fallback_location: painel_products_path, notice: "Produto '#{@product.name}' #{status_msg}."
          end
        end
      else
        redirect_back fallback_location: painel_products_path, alert: "Não foi possível alterar a disponibilidade: #{@product.errors.full_messages.to_sentence}"
      end
    end

    def purge_image
      image = @product.images.find_by(id: params[:image_id])
      if image
        image.purge
        redirect_to edit_painel_product_path(@product), notice: "Imagem removida com sucesso."
      else
        redirect_to edit_painel_product_path(@product), alert: "Foto não encontrada ou já removida."
      end
    end

    def destroy
      name = @product.name
      @product.destroy
      redirect_to painel_products_path, notice: "Produto '#{name}' excluído com sucesso!"
    end

    private

    def set_product
      @product = @current_business.products.find_by(slug: params[:id]) ||
                 @current_business.products.find_by!(id: params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :category_id, :description, :price, :promotional_price,
        :available, images: []
      )
    end
  end
end
