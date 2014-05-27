# Google analytics ID
GA.tracker = Configuration['google_analytics_id'] if Rails.env.production? && Configuration['google_analytics_id'].present? && ActiveRecord::Base.connection.tables.include?(::Configuration.table_name)
