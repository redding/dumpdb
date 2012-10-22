# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dumpdb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "dumpdb"
  gem.version     = Dumpdb::VERSION
  gem.description = %q{Dump and restore your databases.}
  gem.summary     = %q{Dump and restore your databases.}

  gem.authors     = ["Kelly Redding"]
  gem.email       = ["kelly@kellyredding.com"]
  gem.homepage    = "http://github.com/redding/dumpdb"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert")
  gem.add_dependency("scmd", ["~>1.1"])
end
