require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Loja Tech",
      business_type: "store",
      city: "Teixeira de Freitas",
      state: "BA"
    )
    @category = Category.create!(name: "Acessórios", category_type: "product")
  end

  test "valid product creation and slugging" do
    product = @business.products.create!(
      category: @category,
      name: "Copo Térmico 473ml",
      price: 100.00,
      promotional_price: 80.00
    )

    assert_equal "copo-termico-473ml", product.slug
    assert product.on_sale?
    assert_equal 20, product.discount_percentage
    assert_equal 80.00, product.current_price
  end

  test "validates promotional price must be lower than normal price" do
    product = @business.products.build(
      category: @category,
      name: "Mouse Gamer",
      price: 100.00,
      promotional_price: 120.00
    )

    assert_not product.valid?
    assert_includes product.errors[:promotional_price], "deve ser menor que o preço normal"
  end

  test "validates price presence and non-negativity" do
    product = @business.products.build(
      category: @category,
      name: "Teclado",
      price: -10
    )

    assert_not product.valid?
    assert_includes product.errors[:price], "deve ser maior ou igual a 0"
  end
end
