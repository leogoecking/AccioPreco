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

  test "validates name and phone for quote_request" do
    lead = Lead.new(business: @business, lead_type: "quote_request")
    assert_not lead.valid?
    assert_includes lead.errors[:name], "não pode ficar em branco"
    assert_includes lead.errors[:phone], "não pode ficar em branco"
  end

  test "validates phone format requiring valid DDD and minimum 10 digits" do
    lead = Lead.new(business: @business, lead_type: "quote_request", name: "Maria", phone: "123")
    assert_not lead.valid?
    assert_includes lead.errors[:phone].to_sentence, "deve conter um número válido com DDD"

    lead.phone = "abcdef"
    assert_not lead.valid?
    assert_includes lead.errors[:phone].to_sentence, "deve conter um número válido com DDD"

    lead.phone = "(73) 99999-8888"
    assert lead.valid?

    lead.phone = "73999998888"
    assert lead.valid?
  end

  test "generates polite customer_whatsapp_url when phone is present" do
    lead = Lead.create!(
      business: @business,
      product: @product,
      lead_type: "quote_request",
      name: "João Silva",
      phone: "(73) 99876-5432"
    )

    url = lead.customer_whatsapp_url
    assert_not_nil url
    assert url.start_with?("https://wa.me/5573998765432?text=")
    assert_includes url, "Jo%C3%A3o+Silva"
    assert_includes url, "Cabo+USB"
  end
end
