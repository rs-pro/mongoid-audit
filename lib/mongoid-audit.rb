require 'mongoid'
require 'mongoid-history'
require 'mongoid_userstamp'
require 'kaminari'
require 'kaminari/hooks'
require 'kaminari/models/mongoid_extension'

require 'mongoid-audit/version'
require 'mongoid-audit/trackable'
require 'mongoid-audit/railtie'

begin; require 'rails_admin'; rescue LoadError; end
if defined? ::RailsAdmin
  require "mongoid-audit/rails_admin"
end

Mongoid::History.tracker_class_name = :history_tracker
Mongoid::History.current_user_method = :current_user
Mongoid::History.modifier_class_name = "User"

