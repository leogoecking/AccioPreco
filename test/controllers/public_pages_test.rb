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

  test "inactive businesses products and services return 404 and are excluded from public listings" do
    @business.update!(active: false)

    # Direct access returns 404
    get product_path(@product)
    assert_response :not_found

    get service_path(@service)
    assert_response :not_found

    get business_path(@business)
    assert_response :not_found

    # Excluded from lists
    get products_path
    assert_response :success
    assert_not_includes response.body, "Cabo USB-C"

    get services_path
    assert_response :success
    assert_not_includes response.body, "Troca de Conector"

    get search_path, params: { q: "USB" }
    assert_response :success
    assert_not_includes response.body, "Cabo USB-C"
  end

  test "displays business logo and banner to other users on public business, product, and service pages" do
    @business.logo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sample_logo.png")),
      filename: "sample_logo.png",
      content_type: "image/png"
    )
    @business.banner.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sample_logo.png")),
      filename: "sample_banner.png",
      content_type: "image/png"
    )

    # 1. Public business page shows logo and banner
    get business_path(@business)
    assert_response :success
    assert_select "img[alt='Logo de #{@business.name}']"
    assert_select "img[alt='Banner de #{@business.name}']"

    # 2. Public businesses list shows logo in business card
    get businesses_path
    assert_response :success
    assert_select "img[alt='Logo de #{@business.name}']"

    # 3. Public product page shows logo in 'Vendido por'
    get product_path(@product)
    assert_response :success
    assert_select "img[alt='Logo de #{@business.name}']"

    # 4. Public service page shows logo in 'Prestador responsável'
    get service_path(@service)
    assert_response :success
    assert_select "img[alt='Logo de #{@business.name}']"
  end
end
