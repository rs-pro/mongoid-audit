require 'easy_diff'

module Mongoid
  module Audit
  end
end

require File.expand_path(File.dirname(__FILE__) + '/mongoid/audit')
require File.expand_path(File.dirname(__FILE__) + '/mongoid/audit/version')
require File.expand_path(File.dirname(__FILE__) + '/mongoid/audit/tracker')
require File.expand_path(File.dirname(__FILE__) + '/mongoid/audit/trackable')
require File.expand_path(File.dirname(__FILE__) + '/mongoid/audit/sweeper')

Mongoid::Audit.modifier_class_name = "User"
Mongoid::Audit.trackable_class_options = {}
Mongoid::Audit.current_user_method ||= :current_user

