# config/initializers/sqlite_wal.rb
if Rails.env.production?
  ActiveRecord::Base.connection_pool.with_connection do |conn|
    conn.execute("PRAGMA journal_mode=DELETE;")
    conn.execute("PRAGMA synchronous=NORMAL;")
    Rails.logger.info "SQLite WAL disabled and synchronous set to NORMAL for production"
  rescue => e
    Rails.logger.warn "Could not set SQLite pragmas: #{e.message}"
  end
end