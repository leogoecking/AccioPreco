require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Oficina do Silva",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999881122",
      active: true
    )
    @category = Category.create!(name: "Mecânica", category_type: "both")
    @product = @business.products.create!(
      category: @category,
      name: "Óleo 5W30 Sintético",
      price: 45.00,
      available: true
    )
    @service = @business.services.create!(
      category: @category,
      name: "Troca de Pastilha de Freio",
      starting_price: 90.00,
      active: true
    )
  end

  test "create saves quote_request lead and redirects with notice" do
    assert_difference "Lead.count", 1 do
      post leads_path, params: {
        lead: {
          business_id: @business.id,
          service_id: @service.id,
          name: "João da Silva",
          phone: "73999998888",
          message: "Gostaria de saber o valor para um Fiat Palio."
        }
      }
    end

    lead = Lead.last
    assert_equal "quote_request", lead.lead_type
    assert_equal "João da Silva", lead.name
    assert_equal "73999998888", lead.phone
    assert_equal @business.id, lead.business_id
    assert_equal @service.id, lead.service_id
    assert_redirected_to root_path
    assert_equal "Solicitação de orçamento enviada com sucesso! O estabelecimento entrará em contato via WhatsApp.", flash[:notice]
  end

  test "create handles turbo stream format" do
    assert_difference "Lead.count", 1 do
      post leads_path, params: {
        lead: {
          business_id: @business.id,
          service_id: @service.id,
          name: "Maria Santos",
          phone: "73988887777",
          message: "Preciso com urgência"
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_includes response.media_type, "text/vnd.turbo-stream.html"
    assert_includes response.body, "Solicitação enviada com sucesso!"
  end

  test "create fails when required quote_request fields are blank" do
    assert_no_difference "Lead.count" do
      post leads_path, params: {
        lead: {
          business_id: @business.id,
          service_id: @service.id,
          name: "",
          phone: ""
        }
      }
    end

    assert_redirected_to root_path
    assert_includes flash[:alert], "Erro ao enviar solicitação"
  end

  test "whatsapp_click records lead and redirects to wa.me" do
    assert_difference "Lead.count", 1 do
      get whatsapp_click_path, params: {
        business_id: @business.id,
        product_id: @product.id
      }
    end

    lead = Lead.last
    assert_equal "whatsapp_click", lead.lead_type
    assert_equal @product.id, lead.product_id
    assert_equal @business.id, lead.business_id

    assert_response :redirect
    assert_includes response.redirect_url, "https://wa.me/5573999881122"
    assert_includes response.redirect_url, CGI.escape(@product.name)
  end

  test "whatsapp_click with service records lead and redirects to wa.me" do
    assert_difference "Lead.count", 1 do
      get whatsapp_click_path, params: {
        business_id: @business.id,
        service_id: @service.id
      }
    end

    lead = Lead.last
    assert_equal "whatsapp_click", lead.lead_type
    assert_equal @service.id, lead.service_id

    assert_response :redirect
    assert_includes response.redirect_url, "https://wa.me/5573999881122"
    assert_includes response.redirect_url, CGI.escape(@service.name)
  end

  test "whatsapp_click for business without whatsapp redirects back with alert" do
    @business.update!(whatsapp: nil)

    assert_difference "Lead.count", 1 do
      get whatsapp_click_path, params: { business_id: @business.id }
    end

    assert_redirected_to business_path(@business)
    assert_equal "Número de WhatsApp não informado por este estabelecimento.", flash[:alert]
  end

  test "safe_whatsapp_target strictly validates https wa.me host and numeric path" do
    controller = LeadsController.new

    assert_includes controller.send(:safe_whatsapp_target, @business, text: "Oi"), "https://wa.me/5573999881122"

    fake_business = Object.new
    def fake_business.whatsapp_url(text: nil); "https://wa.me.attacker.com/5573999881122"; end
    assert_nil controller.send(:safe_whatsapp_target, fake_business, text: "Oi")

    def fake_business.whatsapp_url(text: nil); "http://wa.me/5573999881122"; end
    assert_nil controller.send(:safe_whatsapp_target, fake_business, text: "Oi")

    def fake_business.whatsapp_url(text: nil); "https://wa.me/malicious_path"; end
    assert_nil controller.send(:safe_whatsapp_target, fake_business, text: "Oi")
  end
end
