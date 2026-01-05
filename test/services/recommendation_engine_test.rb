require "test_helper"

class RecommendationEngineTest < ActiveSupport::TestCase
  def setup
    @espresso_profile = taste_profiles(:espresso_user)
    @v60_profile = taste_profiles(:v60_user)
    @wild_profile = taste_profiles(:wild_user)
  end

  # --- Brewing Method Penalty Tests ---

  test "penalizes light roast for espresso users" do
    coffee = coffees(:light_roast_ethiopia)

    engine = RecommendationEngine.new(@espresso_profile)
    score = engine.calculate_method_score(coffee, "espresso")

    assert score < 1.0, "Should penalize light roast on espresso (got #{score})"
    assert_equal 0.5, score
  end

  test "rewards dark roast for espresso users" do
    coffee = coffees(:dark_roast_espresso)

    engine = RecommendationEngine.new(@espresso_profile)
    score = engine.calculate_method_score(coffee, "espresso")

    assert score > 1.0, "Should reward dark roast on espresso (got #{score})"
  end

  test "rewards light roast for V60 users" do
    coffee = coffees(:mantiqueira_fruity)

    engine = RecommendationEngine.new(@v60_profile)
    score = engine.calculate_method_score(coffee, "v60")

    # Light roast base is 1.2, plus acidity bonus 1.1 = 1.32
    assert score >= 1.2, "Should reward light roast on V60 (got #{score})"
  end

  test "penalizes dark roast for V60 users" do
    coffee = coffees(:dark_roast_espresso)

    engine = RecommendationEngine.new(@v60_profile)
    score = engine.calculate_method_score(coffee, "v60")

    assert score < 1.0, "Should penalize dark roast on V60 (got #{score})"
  end

  test "rewards high body coffees for french press" do
    coffee = coffees(:cerrado_classic)  # body: 8

    engine = RecommendationEngine.new(@wild_profile)
    score = engine.calculate_method_score(coffee, "french_press")

    # Medium roast (1.0) + body bonus (1.1) = 1.1
    assert score >= 1.1, "Should reward high body on french press (got #{score})"
  end

  test "rewards high acidity coffees for V60" do
    coffee = coffees(:light_roast_ethiopia)  # acidity: 9

    engine = RecommendationEngine.new(@v60_profile)
    score = engine.calculate_method_score(coffee, "v60")

    # Light roast (1.2) + acidity bonus (1.1) = 1.32
    assert_in_delta 1.32, score, 0.01
  end

  test "moka penalizes light roast" do
    coffee = coffees(:light_roast_ethiopia)

    engine = RecommendationEngine.new(@espresso_profile)
    score = engine.calculate_method_score(coffee, "moka")

    assert_equal 0.6, score
  end

  # --- Integration Tests ---

  test "returns array of recommendations with scores" do
    engine = RecommendationEngine.new(@espresso_profile)

    # This test requires the database to have coffees with embeddings
    # In test environment, we use fixtures which have pre-calculated embeddings
    results = engine.call(limit: 3)

    assert_kind_of Array, results
    results.each do |result|
      assert_kind_of Hash, result
      assert_includes result.keys, :coffee
      assert_includes result.keys, :score
      assert_kind_of Coffee, result[:coffee]
      assert_kind_of Numeric, result[:score]
    end
  end

  test "returns requested number of recommendations" do
    engine = RecommendationEngine.new(@v60_profile)
    results = engine.call(limit: 2)

    assert_equal 2, results.length
  end

  test "results are sorted by score descending" do
    engine = RecommendationEngine.new(@espresso_profile)
    results = engine.call(limit: 3)

    scores = results.map { |r| r[:score] }
    assert_equal scores, scores.sort.reverse
  end

  # --- Target Vector Tests ---

  test "citrus fruit preference maps to high acidity" do
    profile = TasteProfile.new(
      user: users(:one),
      chocolate_preference: "milk",
      fruit_preference: "citrus",
      drink_preference: "wine_light",
      texture_preference: "tea_like",
      adventure_level: "moderate",
      brewing_method: "v60"
    )

    engine = RecommendationEngine.new(profile)
    target = engine.send(:build_target_vector)

    assert_equal 0.9, target[0]  # acidity preference
  end

  test "syrupy texture preference maps to high body" do
    profile = TasteProfile.new(
      user: users(:one),
      chocolate_preference: "dark_85",
      fruit_preference: "dried",
      drink_preference: "beer_stout",
      texture_preference: "syrupy",
      adventure_level: "safe",
      brewing_method: "espresso"
    )

    engine = RecommendationEngine.new(profile)
    target = engine.send(:build_target_vector)

    assert_equal 0.9, target[1]  # body preference
  end

  test "dark_85 chocolate maps to high bitterness and low sweetness" do
    profile = TasteProfile.new(
      user: users(:one),
      chocolate_preference: "dark_85",
      fruit_preference: "dried",
      drink_preference: "beer_stout",
      texture_preference: "syrupy",
      adventure_level: "safe",
      brewing_method: "espresso"
    )

    engine = RecommendationEngine.new(profile)
    target = engine.send(:build_target_vector)

    assert_equal 0.2, target[2]  # sweetness
    assert_equal 0.9, target[3]  # bitterness
  end

  # --- Adventure Level Tests ---

  test "wild users get bonus for light roast" do
    coffee = coffees(:mantiqueira_fruity)

    engine = RecommendationEngine.new(@wild_profile)
    multiplier = engine.send(:adventure_multiplier, coffee)

    assert_equal 1.2, multiplier
  end

  test "safe users get bonus for medium roast" do
    coffee = coffees(:cerrado_classic)

    engine = RecommendationEngine.new(@espresso_profile)
    multiplier = engine.send(:adventure_multiplier, coffee)

    assert_equal 1.1, multiplier
  end

  test "safe users get penalty for non-medium roasts" do
    coffee = coffees(:light_roast_ethiopia)

    engine = RecommendationEngine.new(@espresso_profile)
    multiplier = engine.send(:adventure_multiplier, coffee)

    assert_equal 0.9, multiplier
  end
end
