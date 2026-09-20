require "test_helper"

class PainelControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @business = @user.businesses.create!(
      name: "Tech House",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999881122"
    )
    @category = Category.create!(name: "Periféricos", category_type: "both")
  end

  test "redirects unauthenticated users to login" do
    get painel_path
    assert_redirected_to new_session_path

    get painel_products_path
    assert_redirected_to new_session_path

    get painel_services_path
    assert_redirected_to new_session_path

    get painel_leads_path
    assert_redirected_to new_session_path
  end

  test "authenticated merchant can view dashboard and lists" do
    sign_in_as(@user)

    get painel_path
    assert_response :success

    get painel_business_path
    assert_response :success

    get painel_products_path
    assert_response :success

    get painel_services_path
    assert_response :success

    get painel_leads_path
    assert_response :success
  end

  test "authenticated merchant can create product" do
    sign_in_as(@user)

    assert_difference("@business.products.count", 1) do
      post painel_products_path, params: {
        product: {
          name: "Fone de Ouvido Bluetooth",
          category_id: @category.id,
          price: 89.90,
          description: "Fone com cancelamento de ruído passivo",
          available: true
        }
      }
    end

    assert_redirected_to painel_products_path
  end

  test "authenticated merchant can create service" do
    sign_in_as(@user)

    assert_difference("@business.services.count", 1) do
      post painel_services_path, params: {
        service: {
          name: "Conserto de Teclado",
          category_id: @category.id,
          starting_price: 50.00,
          price_description: "A partir de R$ 50",
          home_service: false,
          active: true
        }
      }
    end

    assert_redirected_to painel_services_path
  end

  test "authenticated merchant can update business info" do
    sign_in_as(@user)

    patch painel_business_path, params: {
      business: {
        name: "Tech House Prime",
        neighborhood: "Centro Histórico"
      }
    }

    assert_redirected_to painel_business_path
    @business.reload
    assert_equal "Tech House Prime", @business.name
    assert_equal "Centro Histórico", @business.neighborhood
  end

  test "user without business can view new business form and create business" do
    new_user = User.create!(
      name: "Novo Comerciante",
      email_address: "novo@comerciante.com",
      password: "password123",
      role: "merchant"
    )
    sign_in_as(new_user)

    get new_painel_business_path
    assert_response :success
    assert_select "form[action='/painel/empresa']"

    assert_difference("Business.count", 1) do
      post painel_business_path, params: {
        business: {
          name: "Lanchonete Central",
          business_type: "store",
          city: "Teixeira de Freitas",
          state: "BA",
          whatsapp: "73999991122"
        }
      }
    end

    assert_redirected_to painel_business_path
    assert_equal "Lanchonete Central", new_user.businesses.first.name
  end

  test "user without business can create business with logo and logo is visible to other users" do
    new_user = User.create!(
      name: "Dona Maria",
      email_address: "maria@padaria.com",
      password: "password123",
      role: "merchant"
    )
    sign_in_as(new_user)

    logo_file = fixture_file_upload("sample_logo.png", "image/png")

    assert_difference("Business.count", 1) do
      post painel_business_path, params: {
        business: {
          name: "Padaria Pão Quente",
          business_type: "store",
          city: "Teixeira de Freitas",
          state: "BA",
          whatsapp: "73999993333",
          logo: logo_file
        }
      }
    end

    business = new_user.businesses.first
    assert business.logo.attached?, "Logo deve estar anexada"

    # Outro usuário (ou visitante público sem login) acessa a página pública
    delete logout_path

    get business_path(business)
    assert_response :success
    assert_select "img[alt='Logo de #{business.name}']"

    get businesses_path
    assert_response :success
    assert_select "img[alt='Logo de #{business.name}']"
  end

  test "authenticated merchant can view edit form and update product using to_param slug" do
    sign_in_as(@user)
    product = @business.products.create!(
      name: "Mouse Sem Fio",
      category: @category,
      price: 59.90
    )

    get edit_painel_product_path(product)
    assert_response :success

    patch painel_product_path(product), params: {
      product: { price: 49.90 }
    }
    assert_redirected_to painel_products_path
    assert_equal 49.90, product.reload.price
  end

  test "authenticated merchant can delete product using to_param slug" do
    sign_in_as(@user)
    product = @business.products.create!(
      name: "Teclado Mecânico",
      category: @category,
      price: 199.90
    )

    assert_difference("@business.products.count", -1) do
      delete painel_product_path(product)
    end
    assert_redirected_to painel_products_path
  end

  test "authenticated merchant can view edit form and update service using to_param slug" do
    sign_in_as(@user)
    service = @business.services.create!(
      name: "Limpeza Preventiva",
      category: @category,
      starting_price: 100.00
    )

    get edit_painel_service_path(service)
    assert_response :success

    patch painel_service_path(service), params: {
      service: { starting_price: 120.00 }
    }
    assert_redirected_to painel_services_path
    assert_equal 120.00, service.reload.starting_price
  end

  test "authenticated merchant can delete service using to_param slug" do
    sign_in_as(@user)
    service = @business.services.create!(
      name: "Formatação Básica",
      category: @category,
      starting_price: 80.00
    )

    assert_difference("@business.services.count", -1) do
      delete painel_service_path(service)
    end
    assert_redirected_to painel_services_path
  end

  test "merchant A cannot access, edit, update or delete products belonging to merchant B" do
    merchant_b = users(:two)
    biz_b = merchant_b.businesses.create!(
      name: "Loja do Concorrente",
      business_type: "store",
      city: "Teixeira de Freitas",
      state: "BA"
    )
    product_b = biz_b.products.create!(
      name: "Produto Exclusivo B",
      category: @category,
      price: 150.00
    )

    # Merchant A is signed in
    sign_in_as(@user)

    get edit_painel_product_path(product_b)
    assert_response :not_found

    patch painel_product_path(product_b), params: { product: { price: 10.00 } }
    assert_response :not_found
    assert_equal 150.00, product_b.reload.price

    delete painel_product_path(product_b)
    assert_response :not_found
    assert Product.exists?(product_b.id)
  end

  test "merchant A cannot view leads belonging to merchant B" do
    merchant_b = users(:two)
    biz_b = merchant_b.businesses.create!(
      name: "Outra Empresa",
      business_type: "store",
      city: "Teixeira de Freitas",
      state: "BA"
    )
    lead_b = biz_b.leads.create!(
      lead_type: "whatsapp_click",
      name: "Cliente Secreto",
      phone: "73999990000"
    )

    # Merchant A is signed in
    sign_in_as(@user)

    get painel_lead_path(lead_b)
    assert_response :not_found
  end

  test "authenticated merchant can toggle product availability" do
    sign_in_as(@user)
    product = @business.products.create!(
      name: "Produto Disponível",
      category: @category,
      price: 100.00,
      available: true
    )

    patch toggle_availability_painel_product_path(product)
    assert_redirected_to painel_products_path
    assert_not product.reload.available?

    patch toggle_availability_painel_product_path(product)
    assert_redirected_to painel_products_path
    assert product.reload.available?
  end

  test "authenticated merchant can toggle service active status" do
    sign_in_as(@user)
    service = @business.services.create!(
      name: "Serviço Ativo",
      category: @category,
      starting_price: 100.00,
      active: true
    )

    patch toggle_active_painel_service_path(service)
    assert_redirected_to painel_services_path
    assert_not service.reload.active?

    patch toggle_active_painel_service_path(service)
    assert_redirected_to painel_services_path
    assert service.reload.active?
  end

  test "merchant cannot self-assign featured true on product or service" do
    sign_in_as(@user)

    post painel_products_path, params: {
      product: {
        name: "Tentativa de Destaque",
        category_id: @category.id,
        price: 50.00,
        featured: true
      }
    }
    product = @business.products.find_by(name: "Tentativa de Destaque")
    assert_not_nil product
    assert_not product.featured?, "Comerciante não deve conseguir se auto-destacar"

    post painel_services_path, params: {
      service: {
        name: "Serviço Sem Destaque",
        category_id: @category.id,
        starting_price: 50.00,
        featured: true
      }
    }
    service = @business.services.find_by(name: "Serviço Sem Destaque")
    assert_not_nil service
    assert_not service.featured?, "Comerciante não deve conseguir se auto-destacar em serviço"
  end

  test "merchant can view and update account details" do
    sign_in_as(@user)

    get painel_account_path
    assert_response :success

    patch painel_account_path, params: {
      user: {
        name: "Nome Atualizado Comerciante",
        email_address: "atualizado@comerciante.com"
      }
    }
    assert_redirected_to painel_account_path
    @user.reload
    assert_equal "Nome Atualizado Comerciante", @user.name
    assert_equal "atualizado@comerciante.com", @user.email_address
  end

  test "merchant can change password when providing valid current password" do
    sign_in_as(@user)

    # Wrong current password fails
    patch painel_account_path, params: {
      user: {
        current_password: "wrongpassword",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_response :unprocessable_entity
    assert_not @user.reload.authenticate("newpassword123")

    # Correct current password succeeds
    patch painel_account_path, params: {
      user: {
        current_password: "password",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_redirected_to painel_account_path
    assert @user.reload.authenticate("newpassword123")
  end

  test "merchant can filter leads by type" do
    sign_in_as(@user)
    @business.leads.create!(lead_type: "whatsapp_click")
    @business.leads.create!(lead_type: "quote_request", name: "Carlos", phone: "73999992222")

    get painel_leads_path(type: "whatsapp")
    assert_response :success
    assert_select "tbody tr", count: 1

    get painel_leads_path(type: "quote")
    assert_response :success
    assert_select "tbody tr", count: 1
  end
end
