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

  test "validates price presence and positivity" do
    product = @business.products.build(
      category: @category,
      name: "Teclado",
      price: 0
    )

    assert_not product.valid?
    assert_includes product.errors[:price], "deve ser maior que 0"

    product.price = -10
    assert_not product.valid?
    assert_includes product.errors[:price], "deve ser maior que 0"
  end

  test "discount_percentage protects against zero division" do
    product = @business.products.build(price: 0, promotional_price: 0)
    assert_equal 0, product.discount_percentage
  end

  test "sanitizes Brazilian currency strings with comma correctly" do
    product = @business.products.build(
      category: @category,
      name: "Produto Brasileiro",
      price: "79,90",
      promotional_price: "59,90"
    )

    assert_equal BigDecimal("79.90"), product.price
    assert_equal BigDecimal("59.90"), product.promotional_price
    assert product.valid?
  end

  test "search_by_text finds products by name and description unaccented" do
    product = @business.products.create!(
      category: @category,
      name: "Cafeteira Elétrica",
      description: "Prepara café expresso cremoso",
      price: 250.00
    )

    assert_includes @business.products.search_by_text("eletrica"), product
    assert_includes @business.products.search_by_text("expresso"), product
    assert_empty @business.products.search_by_text("inexistente")
  end
end
