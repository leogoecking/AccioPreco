class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :category_type, null: false, default: "both"
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :category_type
    add_index :categories, :active
  end
end
