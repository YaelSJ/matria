require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "successful registration shows the confirmation once at the next step" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: { email: "welcome@example.com", password: "password123", password_confirmation: "password123" }
      }
    end

    assert_redirected_to new_case_case_file_path(User.find_by!(email: "welcome@example.com").case)
    follow_redirect!
    assert_select "dialog.registration-success", count: 1
    assert_select "dialog img[src*='ok_matria']", count: 1
    assert_select ".alert-info", count: 0

    get request.path
    assert_select "dialog.registration-success", count: 0
  end

  test "invalid registration does not show a success confirmation" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: { email: "invalid", password: "short", password_confirmation: "different" }
      }
    end

    assert_response :unprocessable_entity
    assert_select "dialog.registration-success", count: 0
    assert_nil flash[:registration_success]
  end
end
