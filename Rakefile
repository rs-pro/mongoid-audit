require "bundler/gem_tasks"

# Get your spec rake tasks working in RSpec 2.0

require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
                                    # Put spec opts in a file named .rspec in root
end
