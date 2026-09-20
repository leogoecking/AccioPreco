# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_19_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "businesses", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address"
    t.string "business_type", default: "store", null: false
    t.string "city", default: "Teixeira de Freitas", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "instagram"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "neighborhood"
    t.string "number"
    t.string "phone"
    t.string "postal_code"
    t.string "slug", null: false
    t.string "state", default: "BA", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified", default: false, null: false
    t.string "whatsapp"
    t.index ["active"], name: "index_businesses_on_active"
    t.index ["business_type"], name: "index_businesses_on_business_type"
    t.index ["city", "state"], name: "index_businesses_on_city_and_state"
    t.index ["slug"], name: "index_businesses_on_slug", unique: true
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category_type", default: "both", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_categories_on_active"
    t.index ["category_type"], name: "index_categories_on_category_type"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "lead_type", null: false
    t.text "message"
    t.string "name"
    t.string "phone"
    t.bigint "product_id"
    t.bigint "service_id"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_leads_on_business_id"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["lead_type"], name: "index_leads_on_lead_type"
    t.index ["product_id"], name: "index_leads_on_product_id"
    t.index ["service_id"], name: "index_leads_on_service_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.bigint "business_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "promotional_price", precision: 10, scale: 2
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_products_on_available"
    t.index ["business_id", "slug"], name: "index_products_on_business_id_and_slug", unique: true
    t.index ["business_id"], name: "index_products_on_business_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["slug"], name: "index_products_on_slug"
  end

  create_table "services", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "business_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.boolean "home_service", default: false, null: false
    t.string "name", null: false
    t.string "price_description"
    t.string "slug", null: false
    t.decimal "starting_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_services_on_active"
    t.index ["business_id", "slug"], name: "index_services_on_business_id_and_slug", unique: true
    t.index ["business_id"], name: "index_services_on_business_id"
    t.index ["category_id"], name: "index_services_on_category_id"
    t.index ["featured"], name: "index_services_on_featured"
    t.index ["home_service"], name: "index_services_on_home_service"
    t.index ["slug"], name: "index_services_on_slug"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "merchant", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "businesses", "users"
  add_foreign_key "leads", "businesses"
  add_foreign_key "leads", "products"
  add_foreign_key "leads", "services"
  add_foreign_key "products", "businesses"
  add_foreign_key "products", "categories"
  add_foreign_key "services", "businesses"
  add_foreign_key "services", "categories"
  add_foreign_key "sessions", "users"
end
