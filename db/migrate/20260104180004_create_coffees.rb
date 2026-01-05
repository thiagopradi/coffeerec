class CreateCoffees < ActiveRecord::Migration[8.0]
  def change
    create_table :coffees do |t|
      t.string :name, null: false
      t.text :description
      t.string :roast_level
      t.integer :acidity
      t.integer :body
      t.integer :sweetness
      t.integer :bitterness
      t.vector :flavor_embedding, limit: 8

      t.timestamps
    end
  end
end
