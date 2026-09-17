require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "successful registration shows the confirmation once at the next step" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: { email: "welcome@example.com", password: "password123", password_confirmation: "password123",
                user_country: "México", state: "Ciudad de México", city: "Coyoacán" }
      }
    end

    assert_redirected_to new_case_case_file_path(User.find_by!(email: "welcome@example.com").case)
    follow_redirect!
    assert_select "dialog.registration-success", count: 1
    assert_select "dialog.login-welcome", count: 0
    assert_select "dialog video[playsinline]:not([controls]):not([autoplay]) source[src='/videos/matria-saludo.mp4']", count: 1
    assert_select "dialog h2", text: "Registro Exitoso"
    assert_select "dialog button", text: "¡Continuemos!"
    assert_select "dialog .registration-success__description", count: 0
    assert_select ".alert-info", count: 0

    get request.path
    assert_select "dialog.welcome-video", count: 0
  end

  test "invalid registration does not show a success confirmation" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: { email: "invalid", password: "short", password_confirmation: "different" }
      }
    end

    assert_response :unprocessable_entity
    assert_select "dialog.welcome-video", count: 0
    assert_nil flash[:registration_success]
  end
  test "registration renders ordered location lists without gender or sex" do
    get new_user_registration_path
    assert_response :success
    assert_select "input[name='user[gender]'], input[name='user[sex]']", count: 0
    assert_select "select#user_user_country[required] option", text: "México"
    assert_select "select#user_state[disabled] option", text: "Estado de México"
    assert_select "select#user_city[disabled]"
    assert_select "label[for='user_state']", text: /Estado/
    assert_select "label[for='user_city']", text: %r{Municipio / Alcaldía}
  end

  test "registration rejects a municipality from another state and retains valid selections" do
    assert_no_difference "User.count" do
      post user_registration_path, params: { user: {
        email: "mismatch@example.com", password: "password123", password_confirmation: "password123",
        user_country: "México", state: "Ciudad de México", city: "Toluca"
      } }
    end
    assert_response :unprocessable_entity
    assert_select "select#user_state option[selected]", text: "Ciudad de México"
    assert_select "select#user_city option", text: "Coyoacán"
    assert_select "select#user_city option", text: "Toluca", count: 0
  end

  test "registration preserves canonical location names and ignores removed fields" do
    post user_registration_path, params: { user: {
      email: "canonical@example.com", password: "password123", password_confirmation: "password123",
      user_country: "México", state: "Ciudad de México", city: "Azcapotzalco",
      gender: "ignored", sex: "ignored"
    } }
    user = User.find_by!(email: "canonical@example.com")
    assert_equal ["México", "Ciudad de México", "Azcapotzalco"], [user.user_country, user.state, user.city]
    assert_nil user.gender
    assert_nil user.sex
    assert_redirected_to new_case_case_file_path(user.case)
  end

  test "registration requires a location even when browser checks are bypassed" do
    assert_no_difference "User.count" do
      post user_registration_path, params: { user: {
        email: "missing-location@example.com", password: "password123", password_confirmation: "password123"
      } }
    end
    assert_response :unprocessable_entity
  end
end
