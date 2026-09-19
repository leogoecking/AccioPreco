class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :business, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :promotional_price, precision: 10, scale: 2
      t.boolean :available, null: false, default: true
      t.boolean :featured, null: false, default: false

      t.timestamps
    end

    add_index :products, :slug
    add_index :products, [:business_id, :slug], unique: true
    add_index :products, :available
    add_index :products, :featured
  end
end
