require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "homepage is publicly accessible" do
    get root_path
    assert_response :success
    assert_select "h1", /AccioPreço/
  end

  test "unauthenticated access to painel redirects to login" do
    get painel_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Você precisa entrar para acessar esta área."
  end

  test "authenticated user can access painel" do
    sign_in_as(@user)
    get painel_path
    assert_response :success
    assert_includes response.body, "Olá, #{@user.name}!"
  end
end
