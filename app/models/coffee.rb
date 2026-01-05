class Coffee < ApplicationRecord
  has_neighbors :flavor_embedding

  CURRENCIES = %w[BRL USD EUR].freeze
  CURRENCY_SYMBOLS = { "BRL" => "R$", "USD" => "$", "EUR" => "€" }.freeze

  enum :roast_level, {
    light: "light",
    medium: "medium",
    dark: "dark"
  }, prefix: true

  enum :grind_type, {
    whole_bean: "whole_bean",
    ground: "ground"
  }, prefix: true

  validates :name, presence: true
  validates :acidity, :body, :sweetness, :bitterness,
            numericality: { in: 0..10, allow_nil: true }
  validates :price_cents, numericality: { greater_than: 0, allow_nil: true }
  validates :sku, uniqueness: true, allow_nil: true
  validates :currency, inclusion: { in: CURRENCIES }, allow_nil: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # Returns price as a decimal value
  def price
    return nil unless price_cents
    price_cents / 100.0
  end

  # Returns formatted price with currency symbol
  def formatted_price
    return nil unless price_cents
    symbol = CURRENCY_SYMBOLS[currency] || currency
    "#{symbol} #{'%.2f' % price}"
  end

  # Generate embedding from flavor attributes
  # Vector format: [acidity, body, sweetness, bitterness, fruity, chocolatey, nutty, floral]
  def generate_embedding!
    self.flavor_embedding = [
      normalize(acidity),
      normalize(body),
      normalize(sweetness),
      normalize(bitterness),
      fruity_score,
      chocolatey_score,
      nutty_score,
      floral_score
    ]
    save!
  end

  private

  def normalize(value)
    value.to_f / 10.0
  end

  # Fruity notes correlate with high acidity and moderate sweetness
  def fruity_score
    (acidity.to_f * 0.7 + sweetness.to_f * 0.3) / 10.0
  end

  # Chocolatey notes correlate with body and bitterness
  def chocolatey_score
    (body.to_f * 0.5 + bitterness.to_f * 0.5) / 10.0
  end

  # Nutty notes correlate with body and sweetness
  def nutty_score
    (body.to_f * 0.6 + sweetness.to_f * 0.4) / 10.0
  end

  # Floral notes correlate with high acidity and light body
  def floral_score
    (acidity.to_f * 0.8 + (10 - body.to_f) * 0.2) / 10.0
  end
end
