class AddCommerceAttributesToCoffees < ActiveRecord::Migration[8.0]
  def change
    add_column :coffees, :price_cents, :integer
    add_column :coffees, :currency, :string, default: "BRL"
    add_column :coffees, :url, :string
    add_column :coffees, :sku, :string
    add_column :coffees, :grind_type, :string

    add_index :coffees, :sku, unique: true
  end
end
