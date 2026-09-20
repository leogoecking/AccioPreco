class EnableUnaccentExtension < ActiveRecord::Migration[8.1]
  def change
    enable_extension "unaccent" unless extension_enabled?("unaccent")
  end
end
