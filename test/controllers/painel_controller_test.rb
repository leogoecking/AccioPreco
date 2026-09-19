require "test_helper"

class PainelControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Tech House",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999881122"
    )
    @category = Category.create!(name: "Periféricos", category_type: "both")
  end

  test "redirects unauthenticated users to login" do
    get painel_path
    assert_redirected_to new_session_path

    get painel_products_path
    assert_redirected_to new_session_path

    get painel_services_path
    assert_redirected_to new_session_path

    get painel_leads_path
    assert_redirected_to new_session_path
  end

  test "authenticated merchant can view dashboard and lists" do
    sign_in_as(@user)

    get painel_path
    assert_response :success

    get painel_business_path
    assert_response :success

    get painel_products_path
    assert_response :success

    get painel_services_path
    assert_response :success

    get painel_leads_path
    assert_response :success
  end

  test "authenticated merchant can create product" do
    sign_in_as(@user)

    assert_difference("@business.products.count", 1) do
      post painel_products_path, params: {
        product: {
          name: "Fone de Ouvido Bluetooth",
          category_id: @category.id,
          price: 89.90,
          description: "Fone com cancelamento de ruído passivo",
          available: true
        }
      }
    end

    assert_redirected_to painel_products_path
  end

  test "authenticated merchant can create service" do
    sign_in_as(@user)

    assert_difference("@business.services.count", 1) do
      post painel_services_path, params: {
        service: {
          name: "Conserto de Teclado",
          category_id: @category.id,
          starting_price: 50.00,
          price_description: "A partir de R$ 50",
          home_service: false,
          active: true
        }
      }
    end

    assert_redirected_to painel_services_path
  end

  test "authenticated merchant can update business info" do
    sign_in_as(@user)

    patch painel_business_path, params: {
      business: {
        name: "Tech House Prime",
        neighborhood: "Centro Histórico"
      }
    }

    assert_redirected_to painel_business_path
    @business.reload
    assert_equal "Tech House Prime", @business.name
    assert_equal "Centro Histórico", @business.neighborhood
  end

  test "user without business can view new business form and create business" do
    new_user = User.create!(
      name: "Novo Comerciante",
      email_address: "novo@comerciante.com",
      password: "password123",
      role: "merchant"
    )
    sign_in_as(new_user)

    get new_painel_business_path
    assert_response :success
    assert_select "form[action='/painel/empresa']"

    assert_difference("Business.count", 1) do
      post painel_business_path, params: {
        business: {
          name: "Lanchonete Central",
          business_type: "store",
          city: "Teixeira de Freitas",
          state: "BA",
          whatsapp: "73999991122"
        }
      }
    end

    assert_redirected_to painel_business_path
    assert_equal "Lanchonete Central", new_user.businesses.first.name
  end

  test "authenticated merchant can view edit form and update product using to_param slug" do
    sign_in_as(@user)
    product = @business.products.create!(
      name: "Mouse Sem Fio",
      category: @category,
      price: 59.90
    )

    get edit_painel_product_path(product)
    assert_response :success

    patch painel_product_path(product), params: {
      product: { price: 49.90 }
    }
    assert_redirected_to painel_products_path
    assert_equal 49.90, product.reload.price
  end

  test "authenticated merchant can delete product using to_param slug" do
    sign_in_as(@user)
    product = @business.products.create!(
      name: "Teclado Mecânico",
      category: @category,
      price: 199.90
    )

    assert_difference("@business.products.count", -1) do
      delete painel_product_path(product)
    end
    assert_redirected_to painel_products_path
  end

  test "authenticated merchant can view edit form and update service using to_param slug" do
    sign_in_as(@user)
    service = @business.services.create!(
      name: "Limpeza Preventiva",
      category: @category,
      starting_price: 100.00
    )

    get edit_painel_service_path(service)
    assert_response :success

    patch painel_service_path(service), params: {
      service: { starting_price: 120.00 }
    }
    assert_redirected_to painel_services_path
    assert_equal 120.00, service.reload.starting_price
  end

  test "authenticated merchant can delete service using to_param slug" do
    sign_in_as(@user)
    service = @business.services.create!(
      name: "Formatação Básica",
      category: @category,
      starting_price: 80.00
    )

    assert_difference("@business.services.count", -1) do
      delete painel_service_path(service)
    end
    assert_redirected_to painel_services_path
  end
end
