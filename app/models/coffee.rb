class Coffee < ApplicationRecord
  has_neighbors :flavor_embedding

  enum :roast_level, {
    light: "light",
    medium: "medium",
    dark: "dark"
  }, prefix: true

  validates :name, presence: true
  validates :acidity, :body, :sweetness, :bitterness,
            numericality: { in: 0..10, allow_nil: true }

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
