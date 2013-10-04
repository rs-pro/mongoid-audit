module Mongoid
  module Audit
    class Railtie < Rails::Railtie
      initializer "instantiate observers" do
        config.after_initialize do
          ::Mongoid::Audit.tracker_class.add_observer( ::Mongoid::Audit::Sweeper.instance )
          # install model observer and action controller filter
          if defined?(ActionController) and defined?(ActionController::Base)
            ActionController::Base.class_eval do
              before_filter { |controller| ::Mongoid::Audit::Sweeper.instance.before(controller) }
              after_filter { |controller| ::Mongoid::Audit::Sweeper.instance.after(controller) }
            end
          end
        end
      end
    end
  end
end