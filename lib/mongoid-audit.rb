require 'mongoid-audit/version'
require 'easy_diff'
require 'mongoid'
require 'rails-observers'
require 'rails/observers/active_model/active_model'

module Mongoid
  module Audit
    mattr_accessor :tracker_class_name
    mattr_accessor :trackable_class_options
    mattr_accessor :modifier_class_name
    mattr_accessor :current_user_method

    def self.tracker_class
      @tracker_class ||= tracker_class_name.to_s.classify.constantize
    end
  end
end

if defined? Rails::Railtie
  require 'mongoid-audit/railtie'
end

if Object.const_defined?("RailsAdmin")
  require "mongoid-audit/rails_admin"
end

require 'mongoid-audit/tracker'
require 'mongoid-audit/trackable'
require 'mongoid-audit/sweeper'

Mongoid::Audit.modifier_class_name = "User"
Mongoid::Audit.trackable_class_options = {}
Mongoid::Audit.current_user_method ||= :current_user