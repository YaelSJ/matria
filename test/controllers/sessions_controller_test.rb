require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "successful login shows the returning welcome once without the video" do
    user = User.create!(email: "returning@example.com", password: "password123")
    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_select "dialog.registration-success", count: 1
    assert_select ".registration-success__title", text: "¡Bienvenida!"
    assert_select ".registration-success__description",
                  text: "Me da gusto que estés aquí nuevamente."
    assert_select "dialog.welcome-video", count: 0
    assert_select ".alert-info", count: 0
    get dashboard_path
    assert_select "dialog.registration-success", count: 0
  end

  test "invalid login does not show either welcome" do
    post user_session_path, params: {
      user: { email: "missing@example.com", password: "incorrect" }
    }
    assert_select "dialog.registration-success, dialog.welcome-video", count: 0
    assert_nil flash[:login_success]
  end
end
