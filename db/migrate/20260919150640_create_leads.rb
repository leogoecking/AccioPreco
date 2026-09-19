class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.references :business, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: true
      t.references :service, null: true, foreign_key: true
      t.string :lead_type, null: false
      t.string :name
      t.string :phone
      t.text :message

      t.timestamps
    end

    add_index :leads, :lead_type
    add_index :leads, :created_at
  end
end
