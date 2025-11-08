class CreateSolidCacheSchema < ActiveRecord::Migration[8.1]
  def up
    # Load the schema from cache_schema.rb
    # This migration is for initial setup only
    # Solid Cache tables will be created from the schema file
  end

  def down
    # Remove all solid_cache tables
    drop_table :solid_cache_entries, if_exists: true
  end
end

