class HistoryTracker
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
  include Kaminari::MongoidExtension::Document
end

