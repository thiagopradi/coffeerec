class TasteProfile < ApplicationRecord
  belongs_to :user

  # Chocolate preference maps to sweetness/bitterness
  enum :chocolate_preference, {
    white: "white",       # High sweetness, low bitterness
    milk: "milk",         # Medium sweetness, low bitterness
    dark_70: "dark_70",   # Low sweetness, medium bitterness
    dark_85: "dark_85"    # Very low sweetness, high bitterness
  }, prefix: true

  # Fruit preference maps to acidity and flavor notes
  enum :fruit_preference, {
    citrus: "citrus",     # High acidity, bright flavors
    berries: "berries",   # Medium-high acidity, fruity
    yellow: "yellow",     # Medium acidity, stone fruits
    dried: "dried"        # Low acidity, raisin/date notes
  }, prefix: true

  # Drink preference maps to body and complexity
  enum :drink_preference, {
    wine_bold: "wine_bold",     # Full body, complex
    wine_light: "wine_light",   # Light body, elegant
    beer_ipa: "beer_ipa",       # Bitter, hoppy
    beer_stout: "beer_stout"    # Rich, chocolatey
  }, prefix: true

  # Texture preference maps to body
  enum :texture_preference, {
    tea_like: "tea_like",   # Light body
    creamy: "creamy",       # Medium body
    syrupy: "syrupy"        # Heavy body
  }, prefix: true

  # Adventure level affects recommendation diversity
  enum :adventure_level, {
    safe: "safe",           # Stick to classics
    moderate: "moderate",   # Some experimentation
    wild: "wild"            # Full experimental
  }, prefix: true

  # Brewing method affects roast compatibility
  enum :brewing_method, {
    espresso: "espresso",
    v60: "v60",
    french_press: "french_press",
    moka: "moka",
    capsule: "capsule"
  }, prefix: true

  validates :chocolate_preference, :fruit_preference, :drink_preference,
            :texture_preference, :adventure_level, :brewing_method,
            presence: true
end
