class LeadsController < ApplicationController
  allow_unauthenticated_access

  def create
    @lead = Lead.new(lead_params)
    @lead.lead_type ||= "quote_request"

    respond_to do |format|
      if @lead.save
        format.turbo_stream
        format.html do
          redirect_back fallback_location: root_path,
            notice: "Solicitação de orçamento enviada com sucesso! O estabelecimento entrará em contato via WhatsApp."
        end
      else
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html do
          redirect_back fallback_location: root_path,
            alert: "Erro ao enviar solicitação: #{@lead.errors.full_messages.to_sentence}"
        end
      end
    end
  end

  def whatsapp_click
    @business = Business.active.find(params[:business_id])
    @product = @business.products.available.find_by(id: params[:product_id]) if params[:product_id].present?
    @service = @business.services.active.find_by(id: params[:service_id]) if params[:service_id].present?

    begin
      Lead.create!(
        business: @business,
        product: @product,
        service: @service,
        lead_type: "whatsapp_click"
      )
    rescue StandardError => e
      Rails.logger.error("Erro ao registrar lead de clique no WhatsApp: #{e.message}")
    end

    default_text = if @product
      "Olá! Vi o produto '#{@product.name}' (R$ #{('%.2f' % @product.current_price).tr('.', ',')}) no Accio Preço e gostaria de mais informações."
    elsif @service
      "Olá! Vi o serviço '#{@service.name}' no Accio Preço e gostaria de solicitar um orçamento."
    else
      "Olá! Vi a #{@business.name} no Accio Preço e gostaria de atendimento."
    end

    text = params[:text].presence || default_text
    whatsapp_target = safe_whatsapp_target(@business, text: text)

    if whatsapp_target.present?
      redirect_to whatsapp_target, allow_other_host: true
    else
      redirect_back fallback_location: business_path(@business),
        alert: "Número de WhatsApp não informado por este estabelecimento."
    end
  end

  private

  def safe_whatsapp_target(business, text:)
    raw_url = business.whatsapp_url(text: text)
    return nil if raw_url.blank?

    uri = URI.parse(raw_url)
    return nil unless uri.is_a?(URI::HTTPS) && uri.host == "wa.me" && uri.port == 443
    return nil unless uri.path.match?(%r{\A/\d{10,15}\z})

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  def lead_params
    params.require(:lead).permit(:business_id, :service_id, :product_id, :name, :phone, :message, :lead_type)
  end
end
