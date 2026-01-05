require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", name: "Test User")
    @auth_headers = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "coffee123") }
  end

  test "requires authentication" do
    get admin_users_path
    assert_response :unauthorized
  end

  test "index shows all users" do
    get admin_users_path, headers: @auth_headers
    assert_response :success
    assert_match @user.email, response.body
  end

  test "show displays user details" do
    get admin_user_path(@user), headers: @auth_headers
    assert_response :success
    assert_match @user.email, response.body
  end

  test "new renders form" do
    get new_admin_user_path, headers: @auth_headers
    assert_response :success
  end

  test "create adds new user" do
    assert_difference "User.count", 1 do
      post admin_users_path, params: { user: { email: "new@example.com", name: "New User" } }, headers: @auth_headers
    end
    assert_redirected_to admin_user_path(User.last)
  end

  test "create with invalid data renders form" do
    assert_no_difference "User.count" do
      post admin_users_path, params: { user: { email: "" } }, headers: @auth_headers
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    get edit_admin_user_path(@user), headers: @auth_headers
    assert_response :success
  end

  test "update modifies user" do
    patch admin_user_path(@user), params: { user: { name: "Updated Name" } }, headers: @auth_headers
    assert_redirected_to admin_user_path(@user)
    @user.reload
    assert_equal "Updated Name", @user.name
  end

  test "destroy removes user" do
    assert_difference "User.count", -1 do
      delete admin_user_path(@user), headers: @auth_headers
    end
    assert_redirected_to admin_users_path
  end
end
