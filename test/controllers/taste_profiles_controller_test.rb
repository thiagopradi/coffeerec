require "test_helper"

class TasteProfilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "quiz@example.com")
  end

  test "redirects to root if not logged in" do
    get new_taste_profile_path
    assert_redirected_to root_path
  end

  test "should get new when logged in" do
    login_as(@user)
    get new_taste_profile_path
    assert_response :success
  end

  test "creates taste profile and redirects to recommendations" do
    login_as(@user)

    assert_difference("TasteProfile.count", 1) do
      post taste_profile_path, params: {
        taste_profile: {
          chocolate_preference: "dark_70",
          fruit_preference: "citrus",
          drink_preference: "wine_light",
          texture_preference: "tea_like",
          adventure_level: "moderate",
          brewing_method: "v60",
          has_grinder: true
        }
      }
    end

    assert_redirected_to recommendations_path
  end

  test "associates taste profile with current user" do
    login_as(@user)

    post taste_profile_path, params: {
      taste_profile: {
        chocolate_preference: "milk",
        fruit_preference: "berries",
        drink_preference: "beer_ipa",
        texture_preference: "creamy",
        adventure_level: "wild",
        brewing_method: "french_press",
        has_grinder: false
      }
    }

    assert_equal @user.id, TasteProfile.last.user_id
  end

  test "renders new with errors for invalid profile" do
    login_as(@user)

    post taste_profile_path, params: {
      taste_profile: {
        chocolate_preference: "dark_70"
        # Missing required fields
      }
    }

    assert_response :unprocessable_entity
  end

  private

  def login_as(user)
    post start_path, params: { user: { email: user.email } }
  end
end
