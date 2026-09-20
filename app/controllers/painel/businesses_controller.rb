module Painel
  class BusinessesController < BaseController
    before_action :require_business!, only: %i[show edit update purge_logo purge_banner]

    def show
      @business = @current_business
      @profile_completion = @business.profile_completion_status
    end

    def new
      if @current_business
        redirect_to painel_business_path and return
      end

      @business = current_user.businesses.build(
        city: "Teixeira de Freitas",
        state: "BA",
        business_type: "store"
      )
    end

    def create
      if @current_business
        redirect_to painel_business_path, alert: "Você já possui uma empresa cadastrada." and return
      end

      clean_params = business_params
      clean_params = clean_params.except(:logo) if clean_params[:logo].blank?
      clean_params = clean_params.except(:banner) if clean_params[:banner].blank?

      @business = current_user.businesses.build(clean_params)
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
      clean_params = business_params
      clean_params = clean_params.except(:logo) if clean_params[:logo].blank?
      clean_params = clean_params.except(:banner) if clean_params[:banner].blank?

      if @business.update(clean_params)
        redirect_to painel_business_path, notice: "Informações da empresa atualizadas com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def purge_logo
      @business = @current_business
      @business.logo.purge if @business.logo.attached?
      redirect_to edit_painel_business_path, notice: "Logotipo removido com sucesso."
    end

    def purge_banner
      @business = @current_business
      @business.banner.purge if @business.banner.attached?
      redirect_to edit_painel_business_path, notice: "Banner removido com sucesso."
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
