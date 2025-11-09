# frozen_string_literal: true

# Optional Solid libraries configuration
# Set environment variables to enable/disable Solid Queue, Cache, and Cable
#
# ENABLE_SOLID_QUEUE=true  - Enable Solid Queue (requires solid_queue tables)
# ENABLE_SOLID_CACHE=true  - Enable Solid Cache (requires solid_cache tables)
# ENABLE_SOLID_CABLE=true  - Enable Solid Cable (requires solid_cable tables)
#
# If not enabled, Rails will use default adapters:
# - Active Job: :async (in-memory)
# - Cache: :memory_store
# - Action Cable: default (redis or async)

Rails.application.configure do
  # Solid Queue configuration
  if ENV['ENABLE_SOLID_QUEUE'] == 'true'
    Rails.logger.info "Solid Queue enabled"
    config.active_job.queue_adapter = :solid_queue
    # Configure database connection for Solid Queue
    if Rails.env.production?
      config.solid_queue.connects_to = { database: { writing: :queue } }
    else
      config.solid_queue.connects_to = { database: { writing: :primary } }
    end
  else
    Rails.logger.info "Solid Queue disabled, using :async adapter"
    # Use async adapter (in-memory, non-persistent)
    config.active_job.queue_adapter = :async
  end

  # Solid Cache configuration
  if ENV['ENABLE_SOLID_CACHE'] == 'true'
    Rails.logger.info "Solid Cache enabled"
    config.cache_store = :solid_cache_store
    # Configure database connection for Solid Cache
    if Rails.env.production?
      config.solid_cache.connects_to = { database: { writing: :cache } }
    else
      config.solid_cache.connects_to = { database: { writing: :primary } }
    end
  else
    Rails.logger.info "Solid Cache disabled, using :memory_store"
    # Use memory store (in-memory, non-persistent)
    config.cache_store = :memory_store
  end

  # Solid Cable configuration is handled separately in cable.yml
  # Configure database connection for Solid Cable
  if ENV['ENABLE_SOLID_CABLE'] == 'true'
    Rails.logger.info "Solid Cable enabled (configure in config/cable.yml)"
    # Configure database connection for Solid Cable
    if Rails.env.production?
      config.solid_cable.connects_to = { database: { writing: :cable } }
    else
      config.solid_cable.connects_to = { database: { writing: :primary } }
    end
  else
    Rails.logger.info "Solid Cable disabled, using default adapter from cable.yml"
  end
end

