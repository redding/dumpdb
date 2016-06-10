require 'assert'
require 'dumpdb/runner'

require 'test/support/fake_cmd_runner'
require 'test/support/test_scripts'

class Dumpdb::Runner

  class UnitTests < Assert::Context
    desc "Dumpdb::Runner"
    setup do
      @fake_cmd_runner = Dumpdb::FakeCmdRunner
      @fake_cmd_runner.reset

      @script = RunnerScript.new
      @runner = Dumpdb::Runner.new(@script, :cmd_runner => @fake_cmd_runner)
    end
    teardown do
      @fake_cmd_runner.reset
    end
    subject{ @runner }

    should have_reader :script, :cmd_runner

    should "run the script" do
      assert_empty @fake_cmd_runner.cmds
      subject.run

      assert_not_empty @fake_cmd_runner.cmds
      assert_equal 7, @fake_cmd_runner.cmds.size
      assert_equal "a restore cmd", @fake_cmd_runner.cmds[-3]
    end

    should "call the callbacks" do
      assert_false @script.all_callbacks_called?
      subject.run

      assert_true @script.all_callbacks_called?
    end

  end

end
