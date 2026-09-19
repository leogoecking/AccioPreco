require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "generates slug automatically from name" do
    business = @user.businesses.create!(
      name: "Casa do Eletricista & Cia",
      business_type: "store",
      city: "Teixeira de Freitas",
      state: "BA"
    )

    assert_equal "casa-do-eletricista-cia", business.slug
    assert_equal business.slug, business.to_param
  end

  test "validates required fields" do
    business = Business.new
    assert_not business.valid?
    assert_includes business.errors[:name], "não pode ficar em branco"
    assert_includes business.errors[:user], "é obrigatório(a)"
  end

  test "validates business_type inclusion" do
    business = @user.businesses.build(name: "Loja X", business_type: "invalid")
    assert_not business.valid?
    assert_includes business.errors[:business_type], "não está incluído na lista"
  end

  test "generates whatsapp url properly" do
    business = @user.businesses.build(
      name: "Tech Test",
      business_type: "store",
      whatsapp: "(73) 99988-1122"
    )

    assert_equal "https://wa.me/5573999881122", business.whatsapp_url
    assert_includes business.whatsapp_url(text: "Olá mundo"), "text=Ol%C3%A1+mundo"
  end

  test "formats full address" do
    business = @user.businesses.build(
      name: "Loja",
      address: "Av. Getúlio Vargas",
      number: "100",
      neighborhood: "Centro",
      city: "Teixeira de Freitas",
      state: "BA"
    )

    assert_equal "Av. Getúlio Vargas, 100 · Centro · Teixeira de Freitas - BA", business.full_address
  end
end
