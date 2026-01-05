require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @auth_headers = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "coffee123") }
  end

  test "requires authentication" do
    get admin_root_path
    assert_response :unauthorized
  end

  test "index shows dashboard with counts" do
    User.create!(email: "dash@example.com")
    Coffee.create!(name: "Dash Coffee", acidity: 5, body: 5, sweetness: 5, bitterness: 5)

    get admin_root_path, headers: @auth_headers
    assert_response :success
    assert_match "Dashboard", response.body
    assert_match "Total Users", response.body
    assert_match "Total Coffees", response.body
  end
end
