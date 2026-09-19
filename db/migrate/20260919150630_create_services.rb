class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :business, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :starting_price, precision: 10, scale: 2
      t.string :price_description
      t.boolean :home_service, null: false, default: false
      t.boolean :featured, null: false, default: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :services, :slug
    add_index :services, [:business_id, :slug], unique: true
    add_index :services, :active
    add_index :services, :featured
    add_index :services, :home_service
  end
end
