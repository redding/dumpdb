require 'dumpdb'

class LocalScript
  include Dumpdb

  databases { 'test/support/database.yaml' }
  dump_file { "dump.#{type}" }
  source    { db('development', :another => 'value') }
  target    { db('test') }

  def type; "local"; end
end

class RemoteScript
  include Dumpdb

  ssh       { 'user@example.com' }
  databases { 'test/support/database.yaml' }
  dump_file { "dump.#{type}" }
  source    { db('development') }
  target    { db('test') }

  def type; "remote"; end
end

class RunnerScript
  include Dumpdb

  dump_file { 'dump.output' }

  dump    { 'a dump cmd' }
  restore { 'a restore cmd' }

  def all_callbacks_called?
    !!(@before_run && @after_run &&
       @before_setup && @after_setup &&
       @before_dump && @after_dump &&
       @before_copy_dump && @after_copy_dump &&
       @before_restore && @after_restore &&
       @before_teardown && @after_teardown
      )
  end

  def before_run;       @before_run       = true; end
  def after_run;        @after_run        = true; end
  def before_setup;     @before_setup     = true; end
  def after_setup;      @after_setup      = true; end
  def before_dump;      @before_dump      = true; end
  def after_dump;       @after_dump       = true; end
  def before_copy_dump; @before_copy_dump = true; end
  def after_copy_dump;  @after_copy_dump  = true; end
  def before_restore;   @before_restore   = true; end
  def after_restore;    @after_restore    = true; end
  def before_teardown;  @before_teardown  = true; end
  def after_teardown;   @after_teardown   = true; end

end
