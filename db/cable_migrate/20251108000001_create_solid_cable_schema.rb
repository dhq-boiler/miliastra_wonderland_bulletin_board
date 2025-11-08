class CreateSolidCableSchema < ActiveRecord::Migration[8.1]
  def up
    # Load the schema from cable_schema.rb
    # This migration is for initial setup only
    # Solid Cable tables will be created from the schema file
  end

  def down
    # Remove all solid_cable tables
    drop_table :solid_cable_messages, if_exists: true
  end
end

