namespace :db do
  namespace :convert do
    desc "Convert PostgreSQL database to SQLite (for development)"
    task pg_to_sqlite: :environment do
      require "yaml"

      # Check if we're in development mode
      unless Rails.env.development?
        puts "Error: This task should only be run in development environment"
        puts "Current environment: #{Rails.env}"
        exit 1
      end

      # PostgreSQL configuration (from environment or defaults)
      pg_config = {
        adapter: "postgresql",
        encoding: "unicode",
        pool: 5,
        database: ENV.fetch("RESTORE_DB_NAME", ENV.fetch("DB_NAME", "miliastra_wonderland_bulletin_board_production")),
        username: ENV.fetch("RESTORE_DB_USERNAME", ENV.fetch("DB_USERNAME", "postgres")),
        password: ENV["RESTORE_DB_PASSWORD"] || ENV["DB_PASSWORD"],
        host: ENV.fetch("RESTORE_DB_HOST", ENV.fetch("DB_HOST", "localhost")),
        port: ENV.fetch("RESTORE_DB_PORT", ENV.fetch("DB_PORT", "5432")).to_i
      }

      puts "=" * 80
      puts "PostgreSQL to SQLite Data Migration"
      puts "=" * 80
      puts "Source (PostgreSQL): #{pg_config[:database]}@#{pg_config[:host]}:#{pg_config[:port]}"
      puts "Target (SQLite): #{ActiveRecord::Base.connection_db_config.database}"
      puts ""

      # Test PostgreSQL connection
      begin
        puts "Testing PostgreSQL connection..."
        pg_connection = ActiveRecord::Base.establish_connection(pg_config)
        pg_tables = ActiveRecord::Base.connection.tables
        puts "✓ Connected successfully. Found #{pg_tables.size} tables."
      rescue => e
        puts "✗ Failed to connect to PostgreSQL: #{e.message}"
        puts ""
        puts "Please ensure:"
        puts "  1. PostgreSQL server is running"
        puts "  2. Database exists and is accessible"
        puts "  3. Credentials are correct (set via RESTORE_DB_* environment variables)"
        exit 1
      end

      # Get current SQLite configuration
      sqlite_config = ActiveRecord::Base.configurations.configs_for(env_name: "development").first.configuration_hash

      # Reconnect to SQLite
      puts ""
      puts "Switching to SQLite (development)..."
      ActiveRecord::Base.establish_connection(:development)

      # Get list of tables to migrate (excluding internal tables)
      excluded_tables = %w[
        schema_migrations
        ar_internal_metadata
      ]

      tables_to_migrate = pg_tables.reject { |t| excluded_tables.include?(t) }

      # Sort tables by dependency order (topological sort)
      puts "Analyzing table dependencies..."
      table_dependencies = {}
      tables_to_migrate.each do |table_name|
        begin
          fks = ActiveRecord::Base.connection.foreign_keys(table_name)
          table_dependencies[table_name] = fks.map(&:to_table).select { |t| tables_to_migrate.include?(t) }
        rescue => e
          table_dependencies[table_name] = []
        end
      end

      # Topological sort
      sorted_tables = []
      remaining_tables = tables_to_migrate.dup

      while remaining_tables.any?
        # Find tables with no dependencies (or all dependencies already sorted)
        ready_tables = remaining_tables.select do |table|
          table_dependencies[table].all? { |dep| sorted_tables.include?(dep) }
        end

        if ready_tables.empty?
          # Circular dependency or unresolvable - just add remaining tables
          puts "  ⚠ Warning: Circular dependencies detected, adding remaining tables in arbitrary order"
          sorted_tables.concat(remaining_tables)
          break
        end

        sorted_tables.concat(ready_tables)
        remaining_tables -= ready_tables
      end

      tables_to_migrate = sorted_tables

      puts "Tables to migrate (dependency order): #{tables_to_migrate.join(', ')}"
      puts ""

      # Show record counts in PostgreSQL
      puts "PostgreSQL record counts:"
      table_counts = {}
      tables_to_migrate.each do |table_name|
        count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{table_name}")
        table_counts[table_name] = count
        if count > 0
          puts "  #{table_name}: #{count} records"
        end
      end
      puts ""

      # Confirm before proceeding
      print "This will REPLACE all data in the SQLite database. Continue? (yes/no): "
      confirmation = $stdin.gets.chomp
      unless confirmation.downcase == "yes"
        puts "Migration cancelled."
        exit 0
      end

      # Clear existing data in SQLite
      puts ""
      puts "Clearing existing data in SQLite..."

      # Temporarily disable foreign key constraints
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")

      ActiveRecord::Base.transaction do
        tables_to_migrate.reverse.each do |table_name|
          begin
            ActiveRecord::Base.connection.execute("DELETE FROM #{table_name}")
            puts "  ✓ Cleared #{table_name}"
          rescue => e
            puts "  ⚠ Could not clear #{table_name}: #{e.message}"
          end
        end
      end

      # Re-enable foreign key constraints
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")

      # Migrate data table by table
      puts ""
      puts "Migrating data..."
      total_records = 0

      # Temporarily disable foreign key constraints for data migration
      ActiveRecord::Base.establish_connection(:development)
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")

      # Get SQLite schema information for each table
      sqlite_schemas = {}
      tables_to_migrate.each do |table_name|
        columns = ActiveRecord::Base.connection.columns(table_name)
        sqlite_schemas[table_name] = columns.map { |col| { name: col.name, type: col.type, null: col.null } }
      end

      tables_to_migrate.each do |table_name|
        # Connect to PostgreSQL to read data
        ActiveRecord::Base.establish_connection(pg_config)
        records = ActiveRecord::Base.connection.select_all("SELECT * FROM #{table_name}")
        record_count = records.length

        if record_count == 0
          puts "  - #{table_name}: (empty)"
          next
        end

        puts "  Processing #{table_name} (#{record_count} records from PostgreSQL)..."

        # Connect to SQLite to write data
        ActiveRecord::Base.establish_connection(:development)

        # Convert records to hash format for proper column mapping
        records_to_insert = records.to_a.map do |record|
          # Convert PostgreSQL specific values to SQLite compatible values
          record.transform_values do |value|
            case value
            when true
              1
            when false
              0
            when Time, DateTime
              value.to_s
            else
              value
            end
          end
        end

        # Insert records in batches using raw SQL to bypass validations
        success_count = 0
        error_count = 0
        first_error = nil

        # Get SQLite column order
        sqlite_columns = sqlite_schemas[table_name].map { |col| col[:name] }

        records_to_insert.each_with_index do |record, index|
          begin
            # Start with an empty hash and populate all SQLite columns
            full_record = {}

            # First, populate columns that exist in PostgreSQL data
            record.each do |col_name, value|
              full_record[col_name] = value if sqlite_columns.include?(col_name)
            end

            # Then, add missing columns with default values (only for NOT NULL columns)
            sqlite_schemas[table_name].each do |col_info|
              col_name = col_info[:name]
              is_missing = !full_record.key?(col_name)
              is_null = full_record.key?(col_name) && full_record[col_name].nil?

              # If column is missing or NULL, apply default value ONLY if NOT NULL constraint exists
              if is_missing || is_null
                # Skip if NULL is allowed - keep it as NULL
                if col_info[:null]
                  # For nullable columns that are missing, skip them (they'll be NULL)
                  # For nullable columns that are explicitly NULL, keep them as NULL
                  next
                end

                # Only apply defaults for NOT NULL columns
                default_value = case col_info[:type]
                                when :string, :text
                                  ""
                                when :integer, :bigint
                                  0
                                when :boolean
                                  0
                                when :datetime, :timestamp
                                  Time.now.to_s
                                when :date
                                  Date.today.to_s
                                when :decimal, :float
                                  0.0
                                else
                                  ""
                                end

                if index == 0
                  if is_missing
                    puts "    ⚠ Adding missing NOT NULL column '#{col_name}' (#{col_info[:type]}) with default: #{default_value.inspect}"
                  else
                    puts "    ⚠ Replacing NULL in NOT NULL column '#{col_name}' (#{col_info[:type]}) with default: #{default_value.inspect}"
                  end
                end

                full_record[col_name] = default_value
              end
            end

            # Build INSERT statement with explicit column names in SQLite schema order
            columns = sqlite_columns.select { |col| full_record.key?(col) }
            column_names = columns.map { |col| "\"#{col}\"" }.join(", ")
            placeholders = (["?"] * columns.size).join(", ")
            values = columns.map { |col| full_record[col] }

            # Use raw SQL with manual binding to avoid ActiveRecord bind parameter issues
            # Build SQL with properly escaped values
            escaped_values = values.map do |v|
              if v.nil?
                "NULL"
              elsif v.is_a?(Integer)
                v.to_s
              elsif v.is_a?(String)
                "'#{ActiveRecord::Base.connection.quote_string(v)}'"
              else
                "'#{ActiveRecord::Base.connection.quote_string(v.to_s)}'"
              end
            end

            sql = "INSERT INTO #{table_name} (#{column_names}) VALUES (#{escaped_values.join(', ')})"

            if index == 0
              puts "    SQL sample: INSERT INTO #{table_name} (...) VALUES (#{escaped_values.first(3).join(', ')}, ...)"
            end

            ActiveRecord::Base.connection.execute(sql)
            success_count += 1
          rescue => e
            error_count += 1
            if first_error.nil?
              first_error = e
              puts "    First error at record #{index + 1}: #{e.message}"
              puts "    Expected columns (#{columns.size}): #{columns.join(', ')}"
              puts "    Values (#{values.size}): #{values.map { |v| v.nil? ? 'NULL' : v.to_s.truncate(30) }.join(', ')}"

              # Show column-value mapping
              puts "    Column-Value mapping:"
              columns.each_with_index do |col, i|
                val = values[i]
                val_display = val.nil? ? 'NULL' : val.to_s.truncate(30)
                puts "      #{col} => #{val_display}"
              end
            end
          end
        end

        total_records += success_count

        if error_count > 0
          puts "  ⚠ #{table_name}: #{success_count}/#{record_count} records migrated, #{error_count} skipped"
        else
          puts "  ✓ #{table_name}: #{success_count} records"
        end
      end

      # Re-enable foreign key constraints
      ActiveRecord::Base.establish_connection(:development)
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")

      # Final summary
      puts ""
      puts "=" * 80
      puts "Migration completed!"
      puts "Total records migrated: #{total_records}"
      puts "=" * 80

      # Reconnect to development (SQLite) for subsequent operations
      ActiveRecord::Base.establish_connection(:development)
    end
  end
end