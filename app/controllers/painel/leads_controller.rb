module Painel
  class LeadsController < BaseController
    before_action :require_business!

    def index
      scope = @current_business.leads.recent.includes(:product, :service)

      @total_count = @current_business.leads.count
      @whatsapp_count = @current_business.leads.whatsapp_clicks.count
      @quotes_count = @current_business.leads.quote_requests.count

      case params[:type]
      when "whatsapp"
        scope = scope.whatsapp_clicks
      when "quote"
        scope = scope.quote_requests
      end

      @pagy, @leads = pagy(scope, limit: 15)
    end

    def show
      @lead = @current_business.leads.find(params[:id])
    end
  end
end
