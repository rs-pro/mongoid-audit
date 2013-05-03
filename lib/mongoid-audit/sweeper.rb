module Mongoid::Audit
  class Sweeper < ActiveModel::Observer
    def controller
      Thread.current[:mongoid_history_sweeper_controller]
    end

    def controller=(value)
      Thread.current[:mongoid_history_sweeper_controller] = value
    end

    def self.observed_classes
      [ Mongoid::Audit.tracker_class ]
    end

    # Hook to ActionController::Base#around_filter.
    # Runs before a controller action is run.
    # It should always return true so controller actions
    # can continue.
    def before(controller)
      self.controller = controller
      true
    end

    # Hook to ActionController::Base#around_filter.
    # Runs after a controller action is run.
    # Clean up so that the controller can
    # be collected after this request
    def after(controller)
      self.controller = nil
    end

    def before_create(track)
      track.modifier = audit_current_user if track.modifier.nil?
    end

    def audit_current_user
      if controller.nil?
        nil
      elsif controller.respond_to?(Mongoid::Audit.current_user_method, true)
        controller.send Mongoid::Audit.current_user_method
      else
        nil
      end
    end
  end
end
