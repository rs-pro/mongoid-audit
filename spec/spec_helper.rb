require 'coveralls'
Coveralls.wear!

ENV["RAILS_ENV"] ||= 'test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'bundler/setup'
require 'active_support/core_ext'
require 'mongoid'
require 'database_cleaner'

module RailsAdmin
  def self.add_extension(*args); end
end
require "mongoid-audit/rails_admin"

Bundler.require

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require f
end

require 'mongoid-audit'
class HistoryTracker
  include Mongoid::Audit::Tracker
end
