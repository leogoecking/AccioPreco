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
end
