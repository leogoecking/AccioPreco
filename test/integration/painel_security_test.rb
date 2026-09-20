require "test_helper"

class PainelSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @merchant_a = users(:one)
    @biz_a = @merchant_a.businesses.create!(
      name: "Loja Alpha",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999112233"
    )

    @merchant_b = users(:two)
    @biz_b = @merchant_b.businesses.create!(
      name: "Loja Beta",
      business_type: "both",
      city: "Teixeira de Freitas",
      state: "BA",
      whatsapp: "73999445566"
    )

    @product_cat = Category.create!(name: "Eletrônicos Test", category_type: "product")
    @service_cat = Category.create!(name: "Assistência Test", category_type: "service")
    @both_cat = Category.create!(name: "Geral Test", category_type: "both")

    @product_a = @biz_a.products.create!(
      name: "Produto A",
      category: @product_cat,
      price: 100.00
    )

    @product_b = @biz_b.products.create!(
      name: "Produto B",
      category: @product_cat,
      price: 200.00
    )

    @service_a = @biz_a.services.create!(
      name: "Serviço A",
      category: @service_cat,
      starting_price: 80.00
    )

    @service_b = @biz_b.services.create!(
      name: "Serviço B",
      category: @service_cat,
      starting_price: 150.00
    )

    @lead_b = @biz_b.leads.create!(
      lead_type: "whatsapp_click",
      name: "Cliente Secreto",
      phone: "73999887766"
    )
  end

  # --- MULTI-TENANT ISOLATION TESTS ---

  test "merchant A cannot access, edit, update or delete products of merchant B" do
    sign_in_as(@merchant_a)

    get edit_painel_product_path(@product_b)
    assert_response :not_found

    patch painel_product_path(@product_b), params: { product: { price: 10.00 } }
    assert_response :not_found
    assert_equal 200.00, @product_b.reload.price

    delete painel_product_path(@product_b)
    assert_response :not_found
    assert Product.exists?(@product_b.id)
  end

  test "merchant A cannot access, edit, update or delete services of merchant B" do
    sign_in_as(@merchant_a)

    get edit_painel_service_path(@service_b)
    assert_response :not_found

    patch painel_service_path(@service_b), params: { service: { starting_price: 10.00 } }
    assert_response :not_found
    assert_equal 150.00, @service_b.reload.starting_price

    delete painel_service_path(@service_b)
    assert_response :not_found
    assert Service.exists?(@service_b.id)
  end

  test "merchant A cannot view lead details of merchant B" do
    sign_in_as(@merchant_a)

    get painel_lead_path(@lead_b)
    assert_response :not_found
  end

  test "merchant A cannot purge images from merchant B product or service" do
    sign_in_as(@merchant_a)

    # Fake or cross-tenant image id
    delete purge_image_painel_product_path(@product_a, image_id: 999999)
    assert_redirected_to edit_painel_product_path(@product_a)

    delete purge_image_painel_service_path(@service_a, image_id: 999999)
    assert_redirected_to edit_painel_service_path(@service_a)
  end

  # --- MASS ASSIGNMENT & PRIVILEGE ESCALATION ---

  test "merchant cannot escalate role to admin via account update" do
    sign_in_as(@merchant_a)

    patch painel_account_path, params: {
      user: {
        role: "admin",
        name: "Hacker Merchant"
      }
    }

    assert_redirected_to painel_account_path
    @merchant_a.reload
    assert_equal "merchant", @merchant_a.role
    assert_not @merchant_a.admin?
  end

  test "merchant cannot set business_id on product to steal or reassign business" do
    sign_in_as(@merchant_a)

    post painel_products_path, params: {
      product: {
        name: "Tentativa de Reatribuição",
        category_id: @product_cat.id,
        price: 50.00,
        business_id: @biz_b.id
      }
    }

    product = Product.find_by(name: "Tentativa de Reatribuição")
    assert_not_nil product
    assert_equal @biz_a.id, product.business_id, "Produto deve pertencer estritamente à empresa do usuário logado"
  end

  test "merchant cannot set verified or active directly on business" do
    sign_in_as(@merchant_a)

    patch painel_business_path, params: {
      business: {
        name: "Loja Alpha Modificada",
        verified: true,
        active: false
      }
    }

    @biz_a.reload
    assert_equal "Loja Alpha Modificada", @biz_a.name
    assert_not @biz_a.verified?, "Comerciante não pode auto-verificar empresa"
    assert @biz_a.active?, "Comerciante não pode alterar active via business_params direto"
  end

  # --- MULTIPLE BUSINESS CREATION BUG ---

  test "merchant who already has a business cannot create a second business" do
    sign_in_as(@merchant_a)

    assert_no_difference("Business.count") do
      post painel_business_path, params: {
        business: {
          name: "Segunda Empresa Indevida",
          business_type: "store",
          city: "Teixeira de Freitas",
          state: "BA",
          whatsapp: "73999998888"
        }
      }
    end

    assert_redirected_to painel_business_path
    follow_redirect!
    assert_match(/já possui uma empresa cadastrada/i, response.body)
  end

  # --- CATEGORY COMPATIBILITY VALIDATION ---

  test "product cannot be assigned to service-only category" do
    sign_in_as(@merchant_a)

    assert_no_difference("Product.count") do
      post painel_products_path, params: {
        product: {
          name: "Produto com Categoria Inválida",
          category_id: @service_cat.id,
          price: 50.00
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match(/categoria/i, response.body)
  end

  test "service cannot be assigned to product-only category" do
    sign_in_as(@merchant_a)

    assert_no_difference("Service.count") do
      post painel_services_path, params: {
        service: {
          name: "Serviço com Categoria Inválida",
          category_id: @product_cat.id,
          starting_price: 50.00
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match(/categoria/i, response.body)
  end

  # --- NUMERIC OVERFLOW AND PRICE LIMITS ---

  test "product price rejects numbers >= 100 million to prevent PG numeric field overflow" do
    sign_in_as(@merchant_a)

    assert_no_difference("Product.count") do
      post painel_products_path, params: {
        product: {
          name: "Produto Muito Caro",
          category_id: @product_cat.id,
          price: "9999999999"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "service starting_price rejects numbers >= 100 million" do
    sign_in_as(@merchant_a)

    assert_no_difference("Service.count") do
      post painel_services_path, params: {
        service: {
          name: "Serviço Muito Caro",
          category_id: @service_cat.id,
          starting_price: "9999999999"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- BRAZILIAN CURRENCY PARSING ---

  test "product parses Brazilian currency formats correctly" do
    # Thousands with dot: 1.500 -> 1500.00
    p1 = @biz_a.products.build(name: "Item Mil", category: @product_cat, price: "1.500")
    assert_equal 1500.00, p1.price

    # Thousands with dot and cents with comma: 1.299,90 -> 1299.90
    p2 = @biz_a.products.build(name: "Item Complexo", category: @product_cat, price: "1.299,90")
    assert_equal 1299.90, p2.price

    # American format: 1,299.90 -> 1299.90
    p3 = @biz_a.products.build(name: "Item US", category: @product_cat, price: "1,299.90")
    assert_equal 1299.90, p3.price

    # Millions: 1.500.000 -> 1500000.00
    p4 = @biz_a.products.build(name: "Item Milhão", category: @product_cat, price: "1.500.000")
    assert_equal 1500000.00, p4.price
  end

  # --- ACCOUNT PASSWORD CHANGE SILENT FAILURE BUG ---

  test "account update fails validation when current_password is provided without new password" do
    sign_in_as(@merchant_a)

    patch painel_account_path, params: {
      user: {
        current_password: "password",
        password: "",
        password_confirmation: "newpassword"
      }
    }

    assert_response :unprocessable_entity
    assert_match(/senha/i, response.body)
  end

  # --- BUSINESS WHATSAPP VALIDATION ---

  test "business validates whatsapp number format when provided" do
    sign_in_as(@merchant_a)

    patch painel_business_path, params: {
      business: {
        whatsapp: "123" # Inválido
      }
    }

    assert_response :unprocessable_entity
    assert_match(/WhatsApp/i, response.body)
  end

  # --- PAGINATION RESILIENCE ---

  test "painel handles invalid page parameters gracefully without 500" do
    sign_in_as(@merchant_a)

    get painel_products_path(page: -1)
    assert_redirected_to painel_products_path(page: 1)

    get painel_products_path(page: "abc")
    assert_redirected_to painel_products_path(page: 1)

    get painel_services_path(page: 0)
    assert_redirected_to painel_services_path(page: 1)

    get painel_leads_path(page: 999999)
    assert_response :success
  end

  # --- PURGE IMAGE DEFENSIVE ERROR HANDLING ---

  test "purge_image on product handles non-existent or already purged image without 404" do
    sign_in_as(@merchant_a)

    delete purge_image_painel_product_path(@product_a, image_id: 888888)
    assert_redirected_to edit_painel_product_path(@product_a)
    follow_redirect!
    assert_match(/não encontrada ou já removida/i, response.body)
  end

  test "purge_image on service handles non-existent or already purged image without 404" do
    sign_in_as(@merchant_a)

    delete purge_image_painel_service_path(@service_a, image_id: 888888)
    assert_redirected_to edit_painel_service_path(@service_a)
    follow_redirect!
    assert_match(/não encontrada ou já removida/i, response.body)
  end

  # --- TURBO STREAM AVAILABILITY & ACTIVE TOGGLE ---

  test "toggle_availability responds with turbo stream" do
    sign_in_as(@merchant_a)

    patch toggle_availability_painel_product_path(@product_a), as: :turbo_stream
    assert_response :success
    assert_match(/turbo-stream action="replace" target="product_#{@product_a.id}"/, response.body)
  end

  test "toggle_active responds with turbo stream" do
    sign_in_as(@merchant_a)

    patch toggle_active_painel_service_path(@service_a), as: :turbo_stream
    assert_response :success
    assert_match(/turbo-stream action="replace" target="service_#{@service_a.id}"/, response.body)
  end

  # --- CURRENCY FORMATTING IN VIEWS ---

  test "dashboard and product list display prices in Brazilian format with comma" do
    @product_a.update!(price: 79.90, promotional_price: 59.90)
    sign_in_as(@merchant_a)

    get painel_path
    assert_response :success
    assert_match(/R\$ 59,90/, response.body)

    get painel_products_path
    assert_response :success
    assert_match(/R\$ 59,90/, response.body)
    assert_match(/R\$ 79,90/, response.body)
  end

  # --- ONBOARDING FLOW & CANCEL LINK ---

  test "user without business sees cancel link pointing to painel dashboard instead of business path" do
    brand_new_user = User.create!(
      name: "Comerciante Sem Empresa",
      email_address: "sem@empresa.com",
      password: "password123",
      role: "merchant"
    )
    sign_in_as(brand_new_user)

    get new_painel_business_path
    assert_response :success
    assert_select "a[href='/painel']", text: "Cancelar"
  end

  # --- SQL LIKE WILDCARD SEARCH SANITIZATION ---

  test "search handles percent and underscore without distorting query" do
    sign_in_as(@merchant_a)

    get painel_products_path(q: "100%")
    assert_response :success

    get painel_services_path(q: "limpeza_")
    assert_response :success
  end

  # --- EDIT WITH EXISTING IMAGES & NESTED FORM PREVENTION ---

  test "product edit page has no nested forms when images are attached" do
    sign_in_as(@merchant_a)

    # Attach image
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("fake image data"), filename: "test.png", content_type: "image/png")
    @product_a.images.attach(blob)

    get edit_painel_product_path(@product_a)
    assert_response :success
    assert_select "form form", count: 0, message: "No form should ever be nested inside another form"
    assert_select "a[data-turbo-method='delete']", text: "✕"
  end

  test "service edit page has no nested forms when images are attached" do
    sign_in_as(@merchant_a)

    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("fake service img"), filename: "service.png", content_type: "image/png")
    @service_a.images.attach(blob)

    get edit_painel_service_path(@service_a)
    assert_response :success
    assert_select "form form", count: 0, message: "No form should ever be nested inside another form"
    assert_select "a[data-turbo-method='delete']", text: "✕"
  end

  test "business edit page has no nested forms when logo and banner are attached" do
    sign_in_as(@merchant_a)

    blob_logo = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("logo data"), filename: "logo.png", content_type: "image/png")
    blob_banner = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("banner data"), filename: "banner.png", content_type: "image/png")
    @biz_a.logo.attach(blob_logo)
    @biz_a.banner.attach(blob_banner)

    get edit_painel_business_path
    assert_response :success
    assert_select "form form", count: 0, message: "No form should ever be nested inside another form"
    assert_select "a[data-turbo-method='delete']", text: "Remover logotipo"
    assert_select "a[data-turbo-method='delete']", text: "Remover banner"
  end

  test "editing product with existing image without new files preserves existing image" do
    sign_in_as(@merchant_a)

    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("prod img"), filename: "prod.png", content_type: "image/png")
    @product_a.images.attach(blob)
    assert_equal 1, @product_a.images.count

    patch painel_product_path(@product_a), params: {
      product: {
        name: "Produto A Renomeado",
        price: "120.00",
        images: [""]
      }
    }

    assert_redirected_to painel_products_path
    @product_a.reload
    assert_equal "Produto A Renomeado", @product_a.name
    assert_equal 1, @product_a.images.count, "Existing images must not be wiped out when editing without new files"
  end

  test "editing service with existing image without new files preserves existing image" do
    sign_in_as(@merchant_a)

    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("serv img"), filename: "serv.png", content_type: "image/png")
    @service_a.images.attach(blob)
    assert_equal 1, @service_a.images.count

    patch painel_service_path(@service_a), params: {
      service: {
        name: "Serviço A Renomeado",
        starting_price: "90.00",
        images: [""]
      }
    }

    assert_redirected_to painel_services_path
    @service_a.reload
    assert_equal "Serviço A Renomeado", @service_a.name
    assert_equal 1, @service_a.images.count, "Existing images must not be wiped out when editing without new files"
  end

  test "editing business preserves logo and banner when no new files are uploaded" do
    sign_in_as(@merchant_a)

    blob_logo = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("logo data"), filename: "logo.png", content_type: "image/png")
    @biz_a.logo.attach(blob_logo)

    patch painel_business_path, params: {
      business: {
        name: "Loja Alpha Renomeada",
        logo: "",
        banner: ""
      }
    }

    assert_redirected_to painel_business_path
    @biz_a.reload
    assert_equal "Loja Alpha Renomeada", @biz_a.name
    assert @biz_a.logo.attached?, "Existing logo must not be detached when updating business info"
  end
end
