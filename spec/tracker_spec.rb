require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Audit::Tracker do
  before :each do
    class MyTracker
      include Mongoid::Audit::Tracker
    end
  end

  after :each do
    Mongoid::Audit.tracker_class_name = nil
  end

  it "should set tracker_class_name when included" do
    Mongoid::Audit.tracker_class_name.should == :my_tracker
  end
end