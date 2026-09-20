require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Auto Elétrica Central",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999881122",
      active: true
    )
    @category = Category.create!(name: "Baterias & Auto Elétrica", category_type: "both")
    @product = @business.products.create!(
      category: @category,
      name: "Bateria Automotiva 60Ah",
      price: 420.00,
      available: true
    )
    @service = @business.services.create!(
      category: @category,
      name: "Troca de Bateria a Domicílio",
      starting_price: 30.00,
      home_service: true,
      active: true
    )
  end

  test "show renders category and its items" do
    get category_path(@category)
    assert_response :success
    assert_select "h1", @category.name
    assert_includes response.body, "Bateria Automotiva 60Ah"
    assert_includes response.body, "Troca de Bateria a Domicílio"
  end

  test "show with type produtos renders products only" do
    get category_path(@category, params: { type: "produtos" })
    assert_response :success
    assert_includes response.body, "Bateria Automotiva 60Ah"
  end

  test "show with type servicos renders services only" do
    get category_path(@category, params: { type: "servicos" })
    assert_response :success
    assert_includes response.body, "Troca de Bateria a Domicílio"
  end

  test "show returns 404 for nonexistent category slug" do
    get category_path(slug: "categoria-que-nao-existe")
    assert_response :not_found
  end
end
