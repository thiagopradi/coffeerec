require "test_helper"

class Admin::MatchesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "matcher@example.com", name: "Match Tester")
    @profile = @user.create_taste_profile!(
      chocolate_preference: "dark_70",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    )

    @coffee = Coffee.create!(
      name: "Match Coffee",
      roast_level: "light",
      acidity: 8,
      body: 5,
      sweetness: 6,
      bitterness: 3
    )
    @coffee.generate_embedding!

    @auth_headers = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "coffee123") }
  end

  test "requires authentication" do
    get admin_matches_path
    assert_response :unauthorized
  end

  test "index shows users with taste profiles" do
    get admin_matches_path, headers: @auth_headers
    assert_response :success
    assert_match @user.email, response.body
  end

  test "index excludes users without profiles" do
    user_no_profile = User.create!(email: "noprofile@example.com")

    get admin_matches_path, headers: @auth_headers
    assert_response :success
    assert_no_match user_no_profile.email, response.body
  end

  test "show displays recommendations for user" do
    get admin_match_path(@user), headers: @auth_headers
    assert_response :success
    assert_match @coffee.name, response.body
    assert_match "match score", response.body
  end

  test "show redirects for user without profile" do
    user_no_profile = User.create!(email: "noprofile@example.com")

    get admin_match_path(user_no_profile), headers: @auth_headers
    assert_redirected_to admin_matches_path
    assert_equal "This user has no taste profile.", flash[:alert]
  end
end
