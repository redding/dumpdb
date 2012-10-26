require 'dumpdb/script'

class LocalScript
  include Dumpdb::Script

  databases { 'test/support/database.yaml' }
  dump_file { "dump.#{type}" }
  source    { db('development', :another => 'value') }
  target    { db('test') }

  def type; "local"; end
end

class RemoteScript
  include Dumpdb::Script

  ssh       { 'user@example.com' }
  databases { 'test/support/database.yaml' }
  dump_file { "dump.#{type}" }
  source    { db('development') }
  target    { db('test') }

  def type; "remote"; end
end
