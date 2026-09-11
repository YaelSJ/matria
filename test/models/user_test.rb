require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "creates a case automatically for a user" do
    user = create_account(:user)

    assert_predicate user.case, :present?
  end

  test "does not create a case for a representative" do
    representative = create_account(:representative)

    assert_nil representative.case
  end

  private

  def create_account(role)
    User.create!(
      email: "#{role}-test-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: role,
      name: "Cuenta",
      last_name: "Prueba"
    )
  end
end
