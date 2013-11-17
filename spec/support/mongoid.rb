Mongoid.configure do |config|
  config.connect_to "mongoid-audit-test"
end

RSpec.configure do |config|
  config.before :each do
    HistoryTracker.add_observer(::Mongoid::Audit::Sweeper.instance)
  end
  config.backtrace_exclusion_patterns = [
    # /\/lib\d*\/ruby\//,
    # /bin\//,
    # /gems/,
    # /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]
end