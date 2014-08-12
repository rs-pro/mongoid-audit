# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid-audit/version'

Gem::Specification.new do |gem|
  gem.name          = "mongoid-audit"
  gem.version       = Mongoid::Audit::VERSION
  gem.authors       = ["Gleb Tv"]
  gem.email         = ["glebtv@gmail.com"]
  gem.description   = %q{Mongoid Audit}
  gem.summary       = %q{Easily track model change history and mantain audit log with mongoid}
  gem.homepage      = "https://github.com/rs-pro/mongoid-audit"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'mongoid', '~> 4.0.0'
  gem.add_dependency 'mongoid-history', '~> 0.4.4'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'kaminari'
  gem.add_dependency 'glebtv_mongoid_userstamp'

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
end

