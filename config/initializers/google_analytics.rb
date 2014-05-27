# Google analytics ID
GA.tracker = Configuration['google_analytics_id'] if Rails.env.production? && ActiveRecord::Base.connection.tables.include?(::Configuration.table_name) && Configuration['google_analytics_id'].present?
