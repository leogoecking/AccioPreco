require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Clima Sul",
      business_type: "service_provider",
      city: "Teixeira de Freitas",
      state: "BA"
    )
    @category = Category.create!(name: "Refrigeração", category_type: "service")
  end

  test "valid service creation and slugging" do
    service = @business.services.create!(
      category: @category,
      name: "Limpeza de Ar-condicionado",
      starting_price: 150.00,
      price_description: "A partir de R$ 150",
      home_service: true
    )

    assert_equal "limpeza-de-ar-condicionado", service.slug
    assert_equal "A partir de R$ 150", service.formatted_price
    assert service.home_service?
  end

  test "formats starting price when description is blank" do
    service = @business.services.build(
      category: @category,
      name: "Troca de filtro",
      starting_price: 80.00
    )

    assert_equal "A partir de R$ 80,00", service.formatted_price
  end

  test "formatted_price returns sob consulta for zero or nil price" do
    service = @business.services.build(
      category: @category,
      name: "Consulta Técnica",
      starting_price: nil
    )
    assert_equal "Sob consulta", service.formatted_price

    service.starting_price = 0
    assert_equal "Sob consulta", service.formatted_price
  end

  test "validates starting_price greater than zero when present" do
    service = @business.services.build(
      category: @category,
      name: "Serviço com Preço Inválido",
      starting_price: 0
    )
    assert_not service.valid?
    assert_includes service.errors[:starting_price], "deve ser maior que 0"
  end

  test "sanitizes Brazilian currency strings with comma correctly" do
    service = @business.services.build(
      category: @category,
      name: "Serviço Sanitizado",
      starting_price: "189,50"
    )

    assert_equal BigDecimal("189.50"), service.starting_price
    assert service.valid?
  end

  test "search_by_text finds services by name and description unaccented" do
    service = @business.services.create!(
      category: @category,
      name: "Manutenção Elétrica Residencial",
      description: "Instalação de tomadas e disjuntores",
      starting_price: 120.00
    )

    assert_includes @business.services.search_by_text("eletrica"), service
    assert_includes @business.services.search_by_text("disjuntores"), service
    assert_empty @business.services.search_by_text("inexistente")
  end
end
