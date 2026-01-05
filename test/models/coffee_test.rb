require "test_helper"

class CoffeeTest < ActiveSupport::TestCase
  test "valid coffee with required attributes" do
    coffee = Coffee.new(name: "Test Coffee")
    assert coffee.valid?
  end

  test "invalid without name" do
    coffee = Coffee.new
    assert_not coffee.valid?
    assert_includes coffee.errors[:name], "can't be blank"
  end

  test "validates acidity range" do
    coffee = Coffee.new(name: "Test", acidity: 11)
    assert_not coffee.valid?
    assert_includes coffee.errors[:acidity], "must be in 0..10"

    coffee.acidity = -1
    assert_not coffee.valid?

    coffee.acidity = 5
    assert coffee.valid?
  end

  test "validates body range" do
    coffee = Coffee.new(name: "Test", body: 11)
    assert_not coffee.valid?

    coffee.body = 7
    assert coffee.valid?
  end

  test "validates sweetness range" do
    coffee = Coffee.new(name: "Test", sweetness: 15)
    assert_not coffee.valid?

    coffee.sweetness = 8
    assert coffee.valid?
  end

  test "validates bitterness range" do
    coffee = Coffee.new(name: "Test", bitterness: 20)
    assert_not coffee.valid?

    coffee.bitterness = 6
    assert coffee.valid?
  end

  test "roast_level enum values" do
    assert_equal %w[light medium dark], Coffee.roast_levels.keys
  end

  test "generate_embedding creates 8-dimensional vector" do
    coffee = Coffee.create!(
      name: "Test Coffee",
      acidity: 7,
      body: 5,
      sweetness: 6,
      bitterness: 4
    )

    coffee.generate_embedding!

    assert_not_nil coffee.flavor_embedding
    assert_equal 8, coffee.flavor_embedding.length
  end

  test "embedding values are normalized between 0 and 1" do
    coffee = Coffee.create!(
      name: "Test Coffee",
      acidity: 10,
      body: 10,
      sweetness: 10,
      bitterness: 10
    )

    coffee.generate_embedding!

    coffee.flavor_embedding.each do |value|
      assert value >= 0 && value <= 1, "Embedding value #{value} should be between 0 and 1"
    end
  end

  test "fruity score calculation" do
    # Fruity = (acidity * 0.7 + sweetness * 0.3) / 10
    coffee = Coffee.create!(
      name: "Test",
      acidity: 8,
      body: 5,
      sweetness: 6,
      bitterness: 3
    )

    coffee.generate_embedding!
    expected_fruity = (8.0 * 0.7 + 6.0 * 0.3) / 10.0  # 0.74

    assert_in_delta expected_fruity, coffee.flavor_embedding[4], 0.01
  end

  test "chocolatey score calculation" do
    # Chocolatey = (body * 0.5 + bitterness * 0.5) / 10
    coffee = Coffee.create!(
      name: "Test",
      acidity: 3,
      body: 8,
      sweetness: 5,
      bitterness: 6
    )

    coffee.generate_embedding!
    expected_chocolatey = (8.0 * 0.5 + 6.0 * 0.5) / 10.0  # 0.7

    assert_in_delta expected_chocolatey, coffee.flavor_embedding[5], 0.01
  end
end
