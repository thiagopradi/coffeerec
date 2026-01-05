class CreateTasteProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :taste_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :chocolate_preference
      t.string :fruit_preference
      t.string :drink_preference
      t.string :texture_preference
      t.string :adventure_level
      t.string :brewing_method
      t.boolean :has_grinder, default: false

      t.timestamps
    end
  end
end
