require "test_helper"

class LeadTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Loja Tech",
      business_type: "store",
      city: "Teixeira de Freitas",
      state: "BA"
    )
    @category = Category.create!(name: "Smartphones", category_type: "product")
    @product = @business.products.create!(
      category: @category,
      name: "Cabo USB",
      price: 25.00
    )
  end

  test "creates valid lead" do
    lead = Lead.create!(
      business: @business,
      product: @product,
      lead_type: "whatsapp_click",
      name: "Cliente Teste",
      phone: "73999990000"
    )

    assert_equal "Cabo USB", lead.target_item_name
    assert_equal "whatsapp_click", lead.lead_type
  end

  test "validates lead_type inclusion" do
    lead = Lead.new(business: @business, lead_type: "invalid_type")
    assert_not lead.valid?
    assert_includes lead.errors[:lead_type], "não está incluído na lista"
  end
end
