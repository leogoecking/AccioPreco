require "test_helper"

class MerchantJourneyTest < ActionDispatch::IntegrationTest
  setup do
    @category_prod = Category.create!(name: "Utilidades", category_type: "product")
    @category_serv = Category.create!(name: "Instalações", category_type: "service")
  end

  test "end-to-end merchant journey: profile, catalog, public search, lead capture, and availability toggle" do
    # 1. Merchant registers/signs in
    merchant = User.create!(
      name: "Rodrigo Comerciante",
      email_address: "rodrigo@comercio.com",
      password: "password",
      role: "merchant"
    )

    sign_in_as(merchant)

    # 2. Accesses panel without business and gets prompted to create business
    get painel_path
    assert_response :success
    assert_select "a[href='/painel/empresa/new']"

    # 3. Creates business
    assert_difference("Business.count", 1) do
      post painel_business_path, params: {
        business: {
          name: "Mundo Térmico Teixeira",
          business_type: "both",
          city: "Teixeira de Freitas",
          state: "BA",
          whatsapp: "(73) 99876-5432",
          address: "Av. Marechal Castelo Branco",
          number: "500",
          neighborhood: "Centro",
          description: "Especializada em copos, garrafas térmicas e gravação a laser personalizada em Teixeira de Freitas."
        }
      }
    end
    assert_redirected_to painel_business_path
    follow_redirect!
    assert_response :success

    business = merchant.businesses.first
    assert_equal "mundo-termico-teixeira", business.slug
    assert business.profile_completion_percentage >= 50

    # 4. Merchant creates a product with Brazilian currency format (79,90)
    assert_difference("business.products.count", 1) do
      post painel_products_path, params: {
        product: {
          name: "Copo Térmico 473ml Inox",
          category_id: @category_prod.id,
          price: "79,90",
          promotional_price: "69,90",
          description: "Mantém a bebida gelada por até 4 horas. Parede dupla com isolamento a vácuo.",
          available: true
        }
      }
    end
    assert_redirected_to painel_products_path
    follow_redirect!
    assert_response :success

    product = business.products.last
    assert_equal BigDecimal("79.90"), product.price
    assert_equal BigDecimal("69.90"), product.promotional_price
    assert product.available?

    # 5. Merchant creates a service
    assert_difference("business.services.count", 1) do
      post painel_services_path, params: {
        service: {
          name: "Gravação a Laser em Copos",
          category_id: @category_serv.id,
          starting_price: "25,00",
          price_description: "A partir de R$ 25 por gravação",
          home_service: false,
          active: true,
          description: "Personalização de nomes e logomarcas a laser em metais."
        }
      }
    end
    assert_redirected_to painel_services_path
    follow_redirect!
    assert_response :success

    service = business.services.last
    assert_equal BigDecimal("25.00"), service.starting_price

    # 6. Check Dashboard metrics
    get painel_path
    assert_response :success
    assert_select "p", text: "Gerenciar produtos →"
    assert_select "span", text: "1" # product count

    # 7. Public visitor searches for "copo termico" (not signed in)
    delete logout_path

    get search_path, params: { q: "copo termico" }
    assert_response :success
    assert_select "h3", text: product.name

    # 8. Public visitor views product page
    get product_path(product)
    assert_response :success
    assert_select "h1", text: product.name

    # 9. Public visitor registers lead: WhatsApp click
    assert_difference("Lead.count", 1) do
      get whatsapp_click_path, params: {
        business_id: business.id,
        product_id: product.id
      }
    end
    assert_response :redirect

    # Public visitor registers lead: Quote request
    assert_difference("Lead.count", 1) do
      post leads_path, params: {
        lead: {
          business_id: business.id,
          product_id: product.id,
          lead_type: "quote_request",
          name: "Lucas Alcantara",
          phone: "(73) 99123-4567",
          message: "Gostaria de saber se tem a cor preta disponível para pronta entrega hoje."
        }
      }
    end
    assert_response :redirect

    # 10. Merchant signs back in and checks leads
    sign_in_as(merchant)

    get painel_leads_path
    assert_response :success
    assert_select "td p", text: "Lucas Alcantara"
    assert_select "td p", text: "(73) 99123-4567"

    # 11. Merchant toggles product availability to unavailable
    patch toggle_availability_painel_product_path(product)
    assert_redirected_to painel_products_path
    assert_not product.reload.available?

    # 12. Public visitor searches again -> product is no longer returned in public search
    delete logout_path
    get search_path, params: { q: "copo termico" }
    assert_response :success
    assert_select "h3", { text: product.name, count: 0 }
  end
end
