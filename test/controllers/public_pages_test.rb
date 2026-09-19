require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Tech House",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999881122"
    )
    @category = Category.create!(name: "Smartphones", category_type: "both")
    @product = @business.products.create!(
      category: @category,
      name: "Cabo USB-C",
      price: 29.90
    )
    @service = @business.services.create!(
      category: @category,
      name: "Troca de Conector",
      starting_price: 80.00
    )
  end

  test "public pages return 200 without authentication" do
    get root_path
    assert_response :success

    get products_path
    assert_response :success

    get product_path(@product)
    assert_response :success
    assert_select "h1", @product.name

    get services_path
    assert_response :success

    get service_path(@service)
    assert_response :success
    assert_select "h1", @service.name

    get businesses_path
    assert_response :success

    get business_path(@business)
    assert_response :success
    assert_select "h1", @business.name

    get search_path, params: { q: "USB" }
    assert_response :success
    assert_includes response.body, "Cabo USB-C"
  end
end
