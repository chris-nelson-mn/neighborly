if Rails.env.production? && ActiveRecord::Base.connection.tables.include?(::Configuration.table_name)
  ActionMailer::Base.asset_host = ::Configuration[:host]
  Rails.application.routes.default_url_options = {host: ::Configuration[:host]} 
else
  Rails.application.routes.default_url_options = {host: 'localhost:5000'} 
end
