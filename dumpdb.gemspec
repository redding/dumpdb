# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dumpdb/version"

Gem::Specification.new do |gem|
  gem.name        = "dumpdb"
  gem.version     = Dumpdb::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = %q{Dump and restore your databases.}
  gem.description = %q{Dump and restore your databases.}
  gem.homepage    = "http://github.com/redding/dumpdb"
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.15.1"])

  gem.add_dependency("scmd",       ["~> 3.0.1"])
  gem.add_dependency("ns-options", ["~> 1.1.6"])
end
