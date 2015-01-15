module Mongoid::Audit
  class Railtie < Rails::Railtie
    config.after_initialize do
      require 'mongoid-audit/history_tracker'
    end
    initializer "mongoid_audit.setup" do
    end
  end
end

