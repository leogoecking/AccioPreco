class CreateBusinesses < ActiveRecord::Migration[8.1]
  def change
    create_table :businesses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :business_type, null: false, default: "store"
      t.string :phone
      t.string :whatsapp
      t.string :instagram
      t.string :email
      t.string :address
      t.string :number
      t.string :neighborhood
      t.string :city, null: false, default: "Teixeira de Freitas"
      t.string :state, null: false, default: "BA"
      t.string :postal_code
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :active, null: false, default: true
      t.boolean :verified, null: false, default: false

      t.timestamps
    end

    add_index :businesses, :slug, unique: true
    add_index :businesses, :business_type
    add_index :businesses, :active
    add_index :businesses, [:city, :state]
  end
end
