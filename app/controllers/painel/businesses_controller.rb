module Painel
  class BusinessesController < BaseController
    def show
      @business = @current_business
    end

    def new
      @business = current_user.businesses.build(
        city: "Teixeira de Freitas",
        state: "BA",
        business_type: "store"
      )
    end

    def create
      @business = current_user.businesses.build(business_params)
      if @business.save
        redirect_to painel_business_path, notice: "Empresa cadastrada com sucesso!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @business = @current_business
    end

    def update
      @business = @current_business
      if @business.update(business_params)
        redirect_to painel_business_path, notice: "Informações da empresa atualizadas com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def business_params
      params.require(:business).permit(
        :name, :description, :business_type, :phone, :whatsapp,
        :instagram, :email, :address, :number, :neighborhood,
        :city, :state, :postal_code, :latitude, :longitude,
        :logo, :banner
      )
    end
  end
end
