require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with name, email and role" do
    user = User.new(
      name: "João Silva",
      email_address: "joao@example.com",
      password: "password123",
      role: "merchant"
    )
    assert user.valid?
  end

  test "requires name" do
    user = User.new(email_address: "teste@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "não pode ficar em branco"
  end

  test "requires valid role" do
    user = User.new(name: "Teste", email_address: "teste@example.com", password: "password123", role: "superadmin")
    assert_not user.valid?
    assert_includes user.errors[:role], "não está incluído na lista"
  end

  test "role helpers" do
    admin = User.new(role: "admin")
    merchant = User.new(role: "merchant")

    assert admin.admin?
    assert_not admin.merchant?

    assert merchant.merchant?
    assert_not merchant.admin?
  end

  test "normalizes email address" do
    user = User.new(email_address: "  UPPER@EXAMPLE.COM  ")
    assert_equal "upper@example.com", user.email_address
  end
end
