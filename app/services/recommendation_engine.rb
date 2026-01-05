# RecommendationEngine
#
# This service encapsulates the core business logic for coffee recommendations.
# It converts a user's TasteProfile into a target vector and finds the most
# similar coffees using pgvector's nearest neighbor search. The results are
# then adjusted based on brewing method compatibility.
#
# Usage:
#   engine = RecommendationEngine.new(taste_profile)
#   recommendations = engine.call(limit: 3)
#   # => [{ coffee: Coffee, score: Float }, ...]
#
class RecommendationEngine
  # Compatibility matrix: brewing_method => { roast_level => multiplier }
  # Values > 1.0 mean good compatibility, < 1.0 mean penalty
  BREWING_PENALTIES = {
    espresso: { light: 0.5, medium: 1.0, dark: 1.2 },
    v60: { light: 1.2, medium: 1.0, dark: 0.7 },
    french_press: { light: 0.8, medium: 1.0, dark: 1.1 },
    moka: { light: 0.6, medium: 1.0, dark: 1.1 },
    capsule: { light: 0.9, medium: 1.0, dark: 1.0 }
  }.freeze

  def initialize(taste_profile)
    @profile = taste_profile
  end

  # Main entry point: returns recommended coffees with scores
  def call(limit: 3)
    target_vector = build_target_vector

    # Get more candidates than needed to allow for score adjustments
    candidates = Coffee.nearest_neighbors(:flavor_embedding, target_vector, distance: "euclidean")
                       .limit(limit * 2)

    candidates
      .map { |coffee| { coffee: coffee, score: calculate_final_score(coffee) } }
      .sort_by { |result| -result[:score] }
      .first(limit)
  end

  # Calculate brewing method compatibility score for a coffee
  # This is exposed publicly for testing
  def calculate_method_score(coffee, method)
    method_sym = method.to_sym
    roast_sym = coffee.roast_level&.to_sym || :medium

    base_multiplier = BREWING_PENALTIES.dig(method_sym, roast_sym) || 1.0

    # Additional adjustments based on coffee characteristics
    case method_sym
    when :french_press
      # French press loves high body coffees
      base_multiplier *= 1.1 if coffee.body && coffee.body >= 7
    when :v60
      # V60 loves high acidity coffees
      base_multiplier *= 1.1 if coffee.acidity && coffee.acidity >= 7
    when :espresso
      # Espresso loves high body + sweetness combo
      if coffee.body && coffee.body >= 8 && coffee.sweetness && coffee.sweetness >= 6
        base_multiplier *= 1.15
      end
    end

    base_multiplier
  end

  private

  # Build an 8-dimensional target vector from taste preferences
  # Vector format: [acidity, body, sweetness, bitterness, fruity, chocolatey, nutty, floral]
  def build_target_vector
    [
      acidity_preference,
      body_preference,
      sweetness_preference,
      bitterness_preference,
      fruity_preference,
      chocolatey_preference,
      nutty_preference,
      floral_preference
    ]
  end

  # Map fruit preference to target acidity
  def acidity_preference
    case @profile.fruit_preference
    when "citrus" then 0.9    # Citrus = high acidity
    when "berries" then 0.7   # Berries = medium-high
    when "yellow" then 0.5    # Stone fruits = medium
    when "dried" then 0.3     # Dried fruits = low acidity
    else 0.5
    end
  end

  # Map texture preference to target body
  def body_preference
    case @profile.texture_preference
    when "syrupy" then 0.9    # Syrupy = heavy body
    when "creamy" then 0.6    # Creamy = medium body
    when "tea_like" then 0.3  # Tea-like = light body
    else 0.5
    end
  end

  # Map chocolate preference to target sweetness
  def sweetness_preference
    case @profile.chocolate_preference
    when "white" then 0.9     # White chocolate = very sweet
    when "milk" then 0.7      # Milk chocolate = sweet
    when "dark_70" then 0.4   # 70% dark = moderate
    when "dark_85" then 0.2   # 85% dark = low sweetness
    else 0.5
    end
  end

  # Map chocolate preference to target bitterness
  def bitterness_preference
    case @profile.chocolate_preference
    when "dark_85" then 0.9   # 85% dark = high bitterness
    when "dark_70" then 0.6   # 70% dark = moderate
    when "milk" then 0.3      # Milk = low bitterness
    when "white" then 0.1     # White = minimal bitterness
    else 0.5
    end
  end

  # Fruity preference based on fruit selection
  def fruity_preference
    %w[citrus berries].include?(@profile.fruit_preference) ? 0.8 : 0.4
  end

  # Chocolatey preference based on chocolate selection
  def chocolatey_preference
    %w[dark_70 dark_85].include?(@profile.chocolate_preference) ? 0.8 : 0.4
  end

  # Nutty preference correlates with stout beer preference
  def nutty_preference
    @profile.drink_preference == "beer_stout" ? 0.7 : 0.4
  end

  # Floral preference correlates with light wine preference
  def floral_preference
    @profile.drink_preference == "wine_light" ? 0.7 : 0.3
  end

  # Calculate final score combining similarity and adjustments
  def calculate_final_score(coffee)
    similarity = calculate_cosine_similarity(build_target_vector, coffee.flavor_embedding)
    method_multiplier = calculate_method_score(coffee, @profile.brewing_method)
    adventure_bonus = adventure_multiplier(coffee)

    similarity * method_multiplier * adventure_bonus
  end

  # Cosine similarity between two vectors
  def calculate_cosine_similarity(vec_a, vec_b)
    return 0.0 if vec_a.nil? || vec_b.nil?

    # Handle the neighbor gem's vector format
    vec_b = vec_b.to_a if vec_b.respond_to?(:to_a)

    dot_product = vec_a.zip(vec_b).sum { |a, b| (a || 0) * (b || 0) }
    magnitude_a = Math.sqrt(vec_a.sum { |x| (x || 0)**2 })
    magnitude_b = Math.sqrt(vec_b.sum { |x| (x || 0)**2 })

    return 0.0 if magnitude_a.zero? || magnitude_b.zero?

    dot_product / (magnitude_a * magnitude_b)
  end

  # Adventure level affects willingness to try different roasts
  def adventure_multiplier(coffee)
    case @profile.adventure_level
    when "wild"
      # Wild users get bonus for light roasts (more experimental)
      coffee.roast_level == "light" ? 1.2 : 1.0
    when "safe"
      # Safe users prefer medium roasts (classic)
      coffee.roast_level == "medium" ? 1.1 : 0.9
    else
      1.0
    end
  end
end
