# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding coffees..."

coffees = [
  {
    name: "Cerrado Mineiro Classic",
    description: "A traditional Brazilian coffee from the Cerrado region with rich chocolate notes, low acidity, and a full, syrupy body. Perfect for espresso lovers and those who enjoy classic Brazilian flavors.",
    roast_level: "medium",
    acidity: 3,
    body: 8,
    sweetness: 7,
    bitterness: 4,
    sku: "CERRADO-001",
    price_cents: 3290,
    currency: "BRL",
    url: "https://example.com/coffees/cerrado-mineiro",
    grind_type: "whole_bean"
  },
  {
    name: "Sul de Minas Balanced",
    description: "A beautifully balanced coffee from southern Minas Gerais featuring yellow fruit notes like peach and apricot, medium acidity, and a creamy body. Versatile for any brewing method.",
    roast_level: "medium",
    acidity: 5,
    body: 6,
    sweetness: 6,
    bitterness: 4,
    sku: "SULMINAS-001",
    price_cents: 2990,
    currency: "BRL",
    url: "https://example.com/coffees/sul-de-minas",
    grind_type: "whole_bean"
  },
  {
    name: "Mantiqueira Fruity",
    description: "A vibrant specialty coffee from the Mantiqueira mountains with bright red berry and citrus notes. Light roast to preserve the delicate, complex flavors. Best for pour-over brewing.",
    roast_level: "light",
    acidity: 8,
    body: 5,
    sweetness: 6,
    bitterness: 3,
    sku: "MANTIQ-001",
    price_cents: 4590,
    currency: "BRL",
    url: "https://example.com/coffees/mantiqueira-fruity",
    grind_type: "whole_bean"
  },
  {
    name: "Caparaó Fermented",
    description: "An experimental natural process coffee from Caparaó with unique wine-like notes and complex fermented flavors. For the adventurous palate seeking something truly distinctive.",
    roast_level: "light",
    acidity: 7,
    body: 7,
    sweetness: 8,
    bitterness: 2,
    sku: "CAPARAO-001",
    price_cents: 5990,
    currency: "BRL",
    url: "https://example.com/coffees/caparao-fermented",
    grind_type: "whole_bean"
  },
  {
    name: "Ethiopian Yirgacheffe",
    description: "A stunning light roast Ethiopian coffee bursting with floral jasmine notes and bright citrus acidity. Tea-like body with a clean, elegant finish. A pour-over lover's dream.",
    roast_level: "light",
    acidity: 9,
    body: 4,
    sweetness: 7,
    bitterness: 2,
    sku: "ETHIOPIA-001",
    price_cents: 6490,
    currency: "BRL",
    url: "https://example.com/coffees/ethiopian-yirgacheffe",
    grind_type: "whole_bean"
  },
  {
    name: "Italian Espresso Blend",
    description: "A classic dark roast blend designed for espresso extraction. Rich chocolate and caramel notes with a heavy, syrupy body and pleasant bitterness. The ultimate traditional espresso experience.",
    roast_level: "dark",
    acidity: 2,
    body: 9,
    sweetness: 5,
    bitterness: 7,
    sku: "ITALIAN-001",
    price_cents: 2490,
    currency: "BRL",
    url: "https://example.com/coffees/italian-espresso",
    grind_type: "ground"
  },
  {
    name: "Colombian Supremo",
    description: "A medium roast Colombian coffee with balanced nutty and caramel notes. Smooth body with mild acidity and a clean finish. A crowd-pleaser for any occasion.",
    roast_level: "medium",
    acidity: 4,
    body: 6,
    sweetness: 7,
    bitterness: 3,
    sku: "COLOMBIA-001",
    price_cents: 3490,
    currency: "BRL",
    url: "https://example.com/coffees/colombian-supremo",
    grind_type: "whole_bean"
  },
  {
    name: "Guatemala Antigua",
    description: "A medium-dark roast from Guatemala's Antigua region. Rich, smoky chocolate notes with hints of spice and a full body. Excellent for french press brewing.",
    roast_level: "medium",
    acidity: 4,
    body: 8,
    sweetness: 5,
    bitterness: 5,
    sku: "GUATEMALA-001",
    price_cents: 3990,
    currency: "BRL",
    url: "https://example.com/coffees/guatemala-antigua",
    grind_type: "ground"
  },
  {
    name: "Kenya AA",
    description: "A bold light-medium roast Kenyan coffee known for its intense berry and blackcurrant notes. High acidity with a wine-like complexity. For those who love bright, complex coffees.",
    roast_level: "light",
    acidity: 9,
    body: 5,
    sweetness: 5,
    bitterness: 4,
    sku: "KENYA-001",
    price_cents: 5490,
    currency: "BRL",
    url: "https://example.com/coffees/kenya-aa",
    grind_type: "whole_bean"
  },
  {
    name: "Sumatra Mandheling",
    description: "A full-bodied dark roast Indonesian coffee with earthy, herbal notes and hints of dark chocolate. Low acidity with a syrupy mouthfeel. Great for those who like bold, distinctive flavors.",
    roast_level: "dark",
    acidity: 2,
    body: 9,
    sweetness: 4,
    bitterness: 6,
    sku: "SUMATRA-001",
    price_cents: 4290,
    currency: "BRL",
    url: "https://example.com/coffees/sumatra-mandheling",
    grind_type: "ground"
  }
]

coffees.each do |coffee_attrs|
  coffee = Coffee.find_or_initialize_by(name: coffee_attrs[:name])
  coffee.assign_attributes(
    description: coffee_attrs[:description],
    roast_level: coffee_attrs[:roast_level],
    acidity: coffee_attrs[:acidity],
    body: coffee_attrs[:body],
    sweetness: coffee_attrs[:sweetness],
    bitterness: coffee_attrs[:bitterness],
    sku: coffee_attrs[:sku],
    price_cents: coffee_attrs[:price_cents],
    currency: coffee_attrs[:currency],
    url: coffee_attrs[:url],
    grind_type: coffee_attrs[:grind_type]
  )
  coffee.save!

  # Generate embeddings for similarity search
  coffee.generate_embedding!
  puts "  Created: #{coffee.name}"
end

puts "Done! Created #{Coffee.count} coffees."
