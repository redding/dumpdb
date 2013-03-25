require 'dumpdb'

class LocalScript
  include Dumpdb

  databases { File.join(ROOT_PATH, 'test/support/database.yaml') }
  dump_file { "dump.#{type}" }
  source    { db('development', :another => 'value') }
  target    { db('test') }

  def type; "local"; end
end

class RemoteScript
  include Dumpdb

  ssh       { 'user@example.com' }
  databases { File.join(ROOT_PATH, 'test/support/database.yaml') }
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

  def initialize
    @before_cmd_run = 0
    @after_cmd_run  = 0
  end

  def all_callbacks_called?
    !!(@before_run && @after_run &&
       @before_setup && @after_setup &&
       @before_dump && @after_dump &&
       @before_copy_dump && @after_copy_dump &&
       @before_restore && @after_restore &&
       @before_teardown && @after_teardown &&
       @before_cmd_run == 7 &&
       @after_cmd_run  == 7
      )
  end

  def before_run(*args);       @before_run       = true; end
  def after_run(*args);        @after_run        = true; end
  def before_setup(*args);     @before_setup     = true; end
  def after_setup(*args);      @after_setup      = true; end
  def before_dump(*args);      @before_dump      = true; end
  def after_dump(*args);       @after_dump       = true; end
  def before_copy_dump(*args); @before_copy_dump = true; end
  def after_copy_dump(*args);  @after_copy_dump  = true; end
  def before_restore(*args);   @before_restore   = true; end
  def after_restore(*args);    @after_restore    = true; end
  def before_teardown(*args);  @before_teardown  = true; end
  def after_teardown(*args);   @after_teardown   = true; end
  def before_cmd_run(*args);   @before_cmd_run   += 1;   end
  def after_cmd_run(*args);    @after_cmd_run    += 1;   end

end
