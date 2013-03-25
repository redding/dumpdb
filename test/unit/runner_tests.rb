require 'assert'
require 'test/support/fake_cmd_runner'
require 'test/support/test_scripts'
require 'dumpdb/runner'

module Dumpdb

  class RunnerTests < Assert::Context
    desc "the runner"
    setup do
      FakeCmdRunner.reset
      @script = RunnerScript.new
      @runner = Runner.new(@script, :cmd_runner => FakeCmdRunner)
    end
    teardown do
      FakeCmdRunner.reset
    end
    subject { @runner }


    should have_reader :script, :cmd_runner

    should "run the script" do
      assert_empty FakeCmdRunner.cmds
      subject.run

      assert_not_empty FakeCmdRunner.cmds
      assert_equal 7, FakeCmdRunner.cmds.size
      assert_equal "a restore cmd", FakeCmdRunner.cmds[-3]
    end

    should "call the callbacks" do
      assert_not @script.all_callbacks_called?
      subject.run

      assert @script.all_callbacks_called?
    end

  end

end
