module Trackable
  extend ActiveSupport::Concern
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  included do
    track_history({
      track_create: true,
      track_destroy: true,
      track_update: true,
      modifier_field: :updater,
      modifier_field_optional: true,
      except: ["created_at", "updated_at", "c_at", "u_at"],
    })
  end
end

