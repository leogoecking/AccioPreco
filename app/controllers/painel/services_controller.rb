module Painel
  class ServicesController < BaseController
    before_action :require_business!
    before_action :set_service, only: %i[show edit update destroy toggle_active purge_image]

    def index
      scope = @current_business.services.recent.includes(:category)
      scope = scope.search_by_text(params[:q]) if params[:q].present?
      scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?

      case params[:status]
      when "active"
        scope = scope.active
      when "inactive"
        scope = scope.where(active: false)
      end

      if params[:home_service] == "true"
        scope = scope.home_services
      elsif params[:home_service] == "false"
        scope = scope.where(home_service: false)
      end

      @pagy, @services = pagy(scope, limit: 12)
      @categories = Category.active.for_services.order(:name)
    end

    def show
      redirect_to edit_painel_service_path(@service)
    end

    def new
      @service = @current_business.services.build(active: true)
      @categories = Category.active.for_services.order(:name)
    end

    def create
      images_to_attach = service_params[:images]&.compact_blank
      clean_params = service_params.except(:images)

      @service = @current_business.services.build(clean_params)
      @service.images.attach(images_to_attach) if images_to_attach.present?

      if @service.save
        redirect_to painel_services_path, notice: "Serviço '#{@service.name}' cadastrado com sucesso!"
      else
        @categories = Category.active.for_services.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.active.for_services.order(:name)
    end

    def update
      images_to_attach = service_params[:images]&.compact_blank
      clean_params = service_params.except(:images)

      @service.assign_attributes(clean_params)
      @service.images.attach(images_to_attach) if images_to_attach.present?

      if @service.save
        redirect_to painel_services_path, notice: "Serviço '#{@service.name}' atualizado com sucesso!"
      else
        @categories = Category.active.for_services.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_active
      new_status = !@service.active
      if @service.update(active: new_status)
        respond_to do |format|
          format.turbo_stream
          format.html do
            status_msg = new_status ? "agora está ativo" : "foi desativado"
            redirect_back fallback_location: painel_services_path, notice: "Serviço '#{@service.name}' #{status_msg}."
          end
        end
      else
        redirect_back fallback_location: painel_services_path, alert: "Não foi possível alterar o status do serviço: #{@service.errors.full_messages.to_sentence}"
      end
    end

    def purge_image
      image = @service.images.find_by(id: params[:image_id])
      if image
        image.purge
        redirect_to edit_painel_service_path(@service), notice: "Imagem removida com sucesso."
      else
        redirect_to edit_painel_service_path(@service), alert: "Foto não encontrada ou já removida."
      end
    end

    def destroy
      name = @service.name
      @service.destroy
      redirect_to painel_services_path, notice: "Serviço '#{name}' excluído com sucesso!"
    end

    private

    def set_service
      @service = @current_business.services.find_by(slug: params[:id]) ||
                 @current_business.services.find_by!(id: params[:id])
    end

    def service_params
      params.require(:service).permit(
        :name, :category_id, :description, :starting_price,
        :price_description, :home_service, :active, images: []
      )
    end
  end
end
