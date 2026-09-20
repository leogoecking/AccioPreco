module Painel
  class DashboardController < BaseController
    def index
      if @current_business
        @products_count = @current_business.products.count
        @available_products_count = @current_business.products.available.count
        @services_count = @current_business.services.count
        @active_services_count = @current_business.services.active.count

        @leads_count = @current_business.leads.count
        @whatsapp_leads_count = @current_business.leads.whatsapp_clicks.count
        @quote_leads_count = @current_business.leads.quote_requests.count

        @profile_completion = @current_business.profile_completion_status

        @recent_leads = @current_business.leads.recent.limit(6).includes(:product, :service)
        @recent_products = @current_business.products.recent.limit(4)
        @recent_services = @current_business.services.recent.limit(4)
      else
        @products_count = 0
        @available_products_count = 0
        @services_count = 0
        @active_services_count = 0
        @leads_count = 0
        @whatsapp_leads_count = 0
        @quote_leads_count = 0
        @profile_completion = { percentage: 0, steps: [], missing_steps: [] }
        @recent_leads = []
        @recent_products = []
        @recent_services = []
      end
    end
  end
end
