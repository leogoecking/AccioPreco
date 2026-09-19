require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "generates slug and validates name" do
    cat = Category.create!(name: "Informática e Games", category_type: "both")
    assert_equal "informatica-e-games", cat.slug
    assert cat.for_products?
    assert cat.for_services?
  end

  test "validates category_type inclusion" do
    cat = Category.new(name: "Teste", category_type: "outro")
    assert_not cat.valid?
    assert_includes cat.errors[:category_type], "não está incluído na lista"
  end

  test "unique name" do
    Category.create!(name: "Construção", category_type: "both")
    dup = Category.new(name: "Construção", category_type: "both")
    assert_not dup.valid?
    assert_includes dup.errors[:name], "já está em uso"
  end
end
