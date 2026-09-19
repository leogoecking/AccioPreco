module Painel
  class BaseController < ApplicationController
    before_action :set_current_business

    layout "painel"

    private

    def set_current_business
      @current_business = current_user&.businesses&.first
    end

    def require_business!
      unless @current_business
        redirect_to new_painel_business_path, alert: "Cadastre sua empresa primeiro para continuar."
      end
    end
  end
end
