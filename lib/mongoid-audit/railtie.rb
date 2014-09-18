module Mongoid::Audit
  class Railtie < Rails::Railtie
    initializer "mongoid_audit.setup" do
      #require_dependency 'history_tracker.rb' if Rails.env.development?
    end
  end
end

