require "test_helper"

class SearchServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Clima & Elétrica Teixeira",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      neighborhood: "Centro",
      whatsapp: "73999887766",
      active: true
    )

    @cat_clima = Category.create!(name: "Ar-condicionado & Refrigeração", category_type: "both")
    @cat_eletrica = Category.create!(name: "Elétrica Residencial", category_type: "both")

    @product_ar = @business.products.create!(
      category: @cat_clima,
      name: "Ar-condicionado Split 12000 BTUs",
      description: "Aparelho inverter econômico e silencioso com gás ecológico",
      price: 2500.00,
      available: true,
      featured: true
    )

    @product_cabo = @business.products.create!(
      category: @cat_eletrica,
      name: "Cabo Flexível 2.5mm",
      description: "Rolo de fio para instalação elétrica antichama",
      price: 180.00,
      available: true,
      featured: false
    )

    @service_ar = @business.services.create!(
      category: @cat_clima,
      name: "Limpeza de Ar-condicionado Split",
      description: "Higienização completa da evaporadora a domicílio",
      starting_price: 150.00,
      home_service: true,
      active: true,
      featured: true
    )

    @service_eletrica = @business.services.create!(
      category: @cat_eletrica,
      name: "Instalação Elétrica Geral",
      description: "Instalação de tomadas e quadros no local do cliente",
      starting_price: 100.00,
      home_service: true,
      active: true,
      featured: false
    )
  end

  test "returns all records when query is empty" do
    result = SearchService.new.call
    assert_includes result[:products], @product_ar
    assert_includes result[:products], @product_cabo
    assert_includes result[:services], @service_ar
    assert_includes result[:services], @service_eletrica
    assert_includes result[:businesses], @business
    assert_equal 2, result[:counts][:products]
    assert_equal 2, result[:counts][:services]
    assert_equal 1, result[:counts][:businesses]
    assert_equal 5, result[:counts][:total]
  end

  test "searches products and services matching name" do
    result = SearchService.new(q: "Ar-condicionado").call
    assert_includes result[:products], @product_ar
    assert_not_includes result[:products], @product_cabo
    assert_includes result[:services], @service_ar
    assert_not_includes result[:services], @service_eletrica
  end

  test "unaccent works for accented searches" do
    # Search without accents finds accented names and descriptions
    result = SearchService.new(q: "eletrica").call
    assert_includes result[:products], @product_cabo
    assert_includes result[:services], @service_eletrica
    assert_includes result[:businesses], @business

    # Search with accent finds unaccented or accented items
    result2 = SearchService.new(q: "elétrica").call
    assert_includes result2[:products], @product_cabo
    assert_includes result2[:services], @service_eletrica
    assert_includes result2[:businesses], @business
  end

  test "multi-word search matches items containing all words" do
    result = SearchService.new(q: "limpeza split").call
    assert_includes result[:services], @service_ar
    assert_not_includes result[:services], @service_eletrica
  end

  test "filters by category" do
    result = SearchService.new(category: @cat_clima.slug).call
    assert_includes result[:products], @product_ar
    assert_not_includes result[:products], @product_cabo
    assert_includes result[:services], @service_ar
    assert_not_includes result[:services], @service_eletrica
  end

  test "filters services by home_service" do
    @service_ar.update!(home_service: false)
    result = SearchService.new(home_service: "1").call
    assert_not_includes result[:services], @service_ar
    assert_includes result[:services], @service_eletrica
  end

  test "excludes unavailable products and inactive services/businesses" do
    @product_ar.update!(available: false)
    @service_ar.update!(active: false)

    result = SearchService.new.call
    assert_not_includes result[:products], @product_ar
    assert_not_includes result[:services], @service_ar

    @business.update!(active: false)
    result_inactive_biz = SearchService.new.call
    assert_not_includes result_inactive_biz[:businesses], @business
    assert_not_includes result_inactive_biz[:products], @product_cabo
    assert_not_includes result_inactive_biz[:services], @service_eletrica
  end
end
