require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login shows the image popup once without the registration video" do
    user = User.create!(email: "returning@example.com", password: "password123")

    post user_session_path, params: { user: { email: user.email, password: "password123" } }

    assert_redirected_to dashboard_path
    follow_redirect!
    assert_select "dialog.login-welcome", count: 1
    assert_select "dialog.login-welcome img[src*='ok_matria']", count: 1
    assert_select "#login-welcome-title", text: "Bienvenida"
    assert_select "#login-welcome-description", text: "Me da gusto verte nuevamente"
    assert_select ".alert-info", count: 0
    assert_select "dialog.registration-success", count: 0
    assert_select "video source[src='/videos/matria-saludo.mp4']", count: 0

    get dashboard_path
    assert_select "dialog.login-welcome", count: 0
    assert_select ".alert-info", count: 0
    assert_select "dialog.registration-success", count: 0
  end

  test "invalid login does not display either welcome" do
    User.create!(email: "failed-login@example.com", password: "password123")
    post user_session_path, params: { user: { email: "failed-login@example.com", password: "incorrect" } }

    assert_response :unprocessable_entity
    assert_select "dialog.login-welcome", count: 0
    assert_select ".alert-info", count: 0
    assert_select "dialog.registration-success", count: 0
  end
end
