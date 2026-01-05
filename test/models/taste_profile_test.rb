require "test_helper"

class TasteProfileTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    # Delete existing taste profile for this user if any
    @user.taste_profile&.destroy
  end

  test "valid taste profile with all preferences" do
    profile = TasteProfile.new(
      user: @user,
      chocolate_preference: "dark_70",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    )
    assert profile.valid?
  end

  test "invalid without user" do
    profile = TasteProfile.new(
      chocolate_preference: "dark_70",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    )
    assert_not profile.valid?
    assert_includes profile.errors[:user], "must exist"
  end

  test "invalid without chocolate_preference" do
    profile = build_profile(chocolate_preference: nil)
    assert_not profile.valid?
    assert_includes profile.errors[:chocolate_preference], "can't be blank"
  end

  test "invalid without fruit_preference" do
    profile = build_profile(fruit_preference: nil)
    assert_not profile.valid?
    assert_includes profile.errors[:fruit_preference], "can't be blank"
  end

  test "invalid without drink_preference" do
    profile = build_profile(drink_preference: nil)
    assert_not profile.valid?
    assert_includes profile.errors[:drink_preference], "can't be blank"
  end

  test "invalid without texture_preference" do
    profile = build_profile(texture_preference: nil)
    assert_not profile.valid?
    assert_includes profile.errors[:texture_preference], "can't be blank"
  end

  test "invalid without adventure_level" do
    profile = build_profile(adventure_level: nil)
    assert_not profile.valid?
    assert_includes profile.errors[:adventure_level], "can't be blank"
  end

  test "invalid without brewing_method" do
    profile = build_profile(brewing_method: nil)
    assert_not profile.valid?
    assert_includes profile.errors[:brewing_method], "can't be blank"
  end

  test "chocolate_preference enum values" do
    assert_equal %w[white milk dark_70 dark_85], TasteProfile.chocolate_preferences.keys
  end

  test "fruit_preference enum values" do
    assert_equal %w[citrus berries yellow dried], TasteProfile.fruit_preferences.keys
  end

  test "drink_preference enum values" do
    assert_equal %w[wine_bold wine_light beer_ipa beer_stout], TasteProfile.drink_preferences.keys
  end

  test "texture_preference enum values" do
    assert_equal %w[tea_like creamy syrupy], TasteProfile.texture_preferences.keys
  end

  test "adventure_level enum values" do
    assert_equal %w[safe moderate wild], TasteProfile.adventure_levels.keys
  end

  test "brewing_method enum values" do
    assert_equal %w[espresso v60 french_press moka capsule], TasteProfile.brewing_methods.keys
  end

  test "has_grinder defaults to false" do
    profile = build_profile
    assert_equal false, profile.has_grinder
  end

  private

  def build_profile(overrides = {})
    defaults = {
      user: @user,
      chocolate_preference: "dark_70",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    }
    TasteProfile.new(defaults.merge(overrides))
  end
end
