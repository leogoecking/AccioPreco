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

  test "generates whatsapp url properly and normalizes various formats" do
    business = @user.businesses.build(
      name: "Tech Test",
      business_type: "store",
      whatsapp: "(73) 99988-1122"
    )

    assert_equal "https://wa.me/5573999881122", business.whatsapp_url
    assert_includes business.whatsapp_url(text: "Olá & mundo? #"), "text=Ol%C3%A1+%26+mundo%3F+%23"

    # Number with leading zero
    business.whatsapp = "073999881122"
    assert_equal "https://wa.me/5573999881122", business.whatsapp_url

    # Number with full international format
    business.whatsapp = "+55 (73) 99988-1122"
    assert_equal "https://wa.me/5573999881122", business.whatsapp_url

    # Short/invalid numbers return nil
    business.whatsapp = "12345"
    assert_nil business.whatsapp_url
    business.whatsapp = ""
    assert_nil business.whatsapp_url
  end

  test "normalizes instagram handles and urls" do
    business = @user.businesses.build(
      name: "Loja",
      business_type: "store",
      instagram: "@minhaloja_tx"
    )

    assert_equal "minhaloja_tx", business.instagram_handle
    assert_equal "https://instagram.com/minhaloja_tx", business.instagram_url

    business.instagram = "https://www.instagram.com/minhaloja_tx/"
    assert_equal "minhaloja_tx", business.instagram_handle
    assert_equal "https://instagram.com/minhaloja_tx", business.instagram_url

    business.instagram = ""
    assert_nil business.instagram_handle
    assert_nil business.instagram_url
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

  test "calculates profile completion status and percentage" do
    business = @user.businesses.build(
      name: "Loja Exemplo",
      business_type: "store",
      city: "Teixeira de Freitas",
      state: "BA"
    )

    # Basic business with only name has 15%
    assert_equal 15, business.profile_completion_percentage
    status = business.profile_completion_status
    assert_equal 15, status[:percentage]
    assert_equal 7, status[:steps].size

    # Adding whatsapp (+20%)
    business.whatsapp = "73999887766"
    assert_equal 35, business.profile_completion_percentage

    # Adding address (+15%)
    business.address = "Rua das Flores"
    business.neighborhood = "Centro"
    assert_equal 50, business.profile_completion_percentage
  end
end
