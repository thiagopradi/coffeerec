require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with email" do
    user = User.new(email: "test@example.com")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid with duplicate email" do
    User.create!(email: "duplicate@example.com")
    user = User.new(email: "duplicate@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "invalid with malformed email" do
    user = User.new(email: "not-an-email")
    assert_not user.valid?
    assert_includes user.errors[:email], "must be a valid email address"
  end

  test "normalizes email to lowercase" do
    user = User.create!(email: "Test@EXAMPLE.com")
    assert_equal "test@example.com", user.email
  end

  test "strips whitespace from email" do
    user = User.create!(email: "  test@example.com  ")
    assert_equal "test@example.com", user.email
  end

  test "has one taste profile" do
    user = users(:one)
    assert_respond_to user, :taste_profile
  end

  test "destroys taste profile when user is destroyed" do
    user = users(:one)
    user.create_taste_profile!(
      chocolate_preference: "dark_70",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    )

    assert_difference "TasteProfile.count", -1 do
      user.destroy
    end
  end
end
