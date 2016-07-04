class HistoryTracker
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
  include Kaminari::Mongoid::MongoidExtension::Document
end

