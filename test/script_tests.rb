require 'assert'

module Dumpdb

  class ScriptTests < Assert::Context
    desc "the script mixin"
    setup do
      @dummy = DummyScript.new
    end
    subject { @dummy }

    should have_cmeths :ssh, :databases, :dump_file, :source, :target
    should have_cmeths :dump, :restore

    should have_imeths :ssh, :databases, :dump_file, :source, :target
    should have_imeths :dump_cmds, :restore_cmds
    should have_imeths :run

    should "store off the `ssh` value for the script" do
      DummyScript.class_eval do
        ssh { 'user@example' }
      end

      assert_equal 'user@example', DummyScript.new.ssh
    end

    should "store off the `databases` value for the script"
    should "store off the `dump_file` value for the script"
    should "store off the `source` value for the script"
    should "store off the `target` value for the script"

    should "store off dump commands for the script"
    should "store off restore commands for the script"

  end

end
