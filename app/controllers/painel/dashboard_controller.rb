module Painel
  class DashboardController < BaseController
    def index
      if @current_business
        @products_count = @current_business.products.count
        @services_count = @current_business.services.count
        @leads_count = @current_business.leads.count

        @recent_leads = @current_business.leads.recent.limit(5).includes(:product, :service)
        @recent_products = @current_business.products.recent.limit(5)
        @recent_services = @current_business.services.recent.limit(5)
      else
        @products_count = 0
        @services_count = 0
        @leads_count = 0
        @recent_leads = []
        @recent_products = []
        @recent_services = []
      end
    end
  end
end
