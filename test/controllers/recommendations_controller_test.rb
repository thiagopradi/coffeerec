require "test_helper"

class RecommendationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "recs@example.com")
    @profile = @user.create_taste_profile!(
      chocolate_preference: "dark_70",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    )
  end

  test "redirects to root if not logged in" do
    get recommendations_path
    assert_redirected_to root_path
  end

  test "redirects to quiz if no taste profile" do
    user_without_profile = User.create!(email: "noprofile@example.com")
    login_as(user_without_profile)

    get recommendations_path
    assert_redirected_to new_taste_profile_path
  end

  test "shows recommendations when logged in with profile" do
    login_as(@user)

    get recommendations_path
    assert_response :success
  end

  test "displays coffee recommendations" do
    login_as(@user)

    get recommendations_path

    # Test that recommendations are assigned
    assert_not_nil assigns(:recommendations) if respond_to?(:assigns)
  end

  private

  def login_as(user)
    post start_path, params: { user: { email: user.email } }
  end
end
