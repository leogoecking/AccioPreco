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
end
