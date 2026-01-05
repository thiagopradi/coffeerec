require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "captures email and redirects to quiz" do
    assert_difference("User.count", 1) do
      post start_path, params: { user: { email: "lead@example.com" } }
    end
    assert_redirected_to new_taste_profile_path
  end

  test "normalizes email before saving" do
    post start_path, params: { user: { email: "  LEAD@EXAMPLE.COM  " } }

    user = User.last
    assert_equal "lead@example.com", user.email
  end

  test "uses existing user if email already exists" do
    existing_user = User.create!(email: "existing@example.com")

    assert_no_difference("User.count") do
      post start_path, params: { user: { email: "existing@example.com" } }
    end

    assert_redirected_to new_taste_profile_path
    assert_equal existing_user.id, session[:user_id]
  end

  test "sets session user_id on successful create" do
    post start_path, params: { user: { email: "session@example.com" } }

    assert_not_nil session[:user_id]
    assert_equal User.find_by(email: "session@example.com").id, session[:user_id]
  end

  test "renders index with errors for invalid email" do
    post start_path, params: { user: { email: "not-an-email" } }

    assert_response :unprocessable_entity
  end

  test "renders index with errors for blank email" do
    assert_no_difference("User.count") do
      post start_path, params: { user: { email: "" } }
    end

    assert_response :unprocessable_entity
  end
end
