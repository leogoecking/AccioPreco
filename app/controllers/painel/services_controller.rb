module Painel
  class ServicesController < BaseController
    before_action :require_business!
    before_action :set_service, only: %i[show edit update destroy]

    def index
      @services = @current_business.services.recent
    end

    def show
    end

    def new
      @service = @current_business.services.build
      @categories = Category.active.for_services
    end

    def create
      @service = @current_business.services.build(service_params)
      if @service.save
        redirect_to painel_services_path, notice: "Serviço cadastrado com sucesso!"
      else
        @categories = Category.active.for_services
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.active.for_services
    end

    def update
      if @service.update(service_params)
        redirect_to painel_services_path, notice: "Serviço atualizado com sucesso!"
      else
        @categories = Category.active.for_services
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @service.destroy
      redirect_to painel_services_path, notice: "Serviço excluído com sucesso!"
    end

    private

    def set_service
      @service = @current_business.services.find_by(slug: params[:id]) ||
                 @current_business.services.find_by!(id: params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :category_id, :description, :starting_price, :price_description, :home_service, :featured, :active, images: [])
    end
  end
end
