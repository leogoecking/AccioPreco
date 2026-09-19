module Painel
  class LeadsController < BaseController
    before_action :require_business!

    def index
      @leads = @current_business.leads.recent.includes(:product, :service)
    end

    def show
      @lead = @current_business.leads.find(params[:id])
    end
  end
end
