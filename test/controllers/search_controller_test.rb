require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Loja Central Teixeira",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      neighborhood: "Centro",
      whatsapp: "73999881122",
      active: true
    )
    @category = Category.create!(name: "Eletrônicos & Áudio", category_type: "both")
    @product = @business.products.create!(
      category: @category,
      name: "Fone Bluetooth Cancelamento de Ruído",
      price: 199.90,
      available: true
    )
    @service = @business.services.create!(
      category: @category,
      name: "Conserto de Fone e Headset",
      starting_price: 50.00,
      active: true
    )
  end

  test "index renders successfully" do
    get search_path
    assert_response :success
    assert_select "input[name='q']"
  end

  test "index with query displays matching product and service" do
    get search_path, params: { q: "Bluetooth" }
    assert_response :success
    assert_includes response.body, "Fone Bluetooth"
  end

  test "index with type produtos renders products tab" do
    get search_path, params: { type: "produtos" }
    assert_response :success
    assert_includes response.body, "Fone Bluetooth"
  end

  test "index with type servicos renders services tab" do
    get search_path, params: { type: "servicos" }
    assert_response :success
    assert_includes response.body, "Conserto de Fone"
  end

  test "index with type empresas renders businesses tab" do
    get search_path, params: { type: "empresas" }
    assert_response :success
    assert_includes response.body, "Loja Central Teixeira"
  end

  test "index displays empty state when no matches" do
    get search_path, params: { q: "item_inexistente_xyz_99" }
    assert_response :success
    assert_includes response.body, "Nenhum resultado encontrado"
  end

  test "pagination handles invalid page numbers like negative or strings without 500" do
    get search_path, params: { type: "produtos", page: "-1" }
    assert_redirected_to search_path(type: "produtos", page: 1)

    get search_path, params: { type: "produtos", page: "abc" }
    assert_redirected_to search_path(type: "produtos", page: 1)
  end
end
