$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'bundler/setup'
require 'active_support/core_ext'
require 'mongoid'
require 'database_cleaner'

Bundler.require

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require f
end

require 'mongoid-audit'

