require 'assert'
require 'dumpdb'

require 'test/support/fake_cmd_runner'
require 'test/support/test_scripts'

module Dumpdb

  class UnitTests < Assert::Context
    desc "Dumpdb"

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @script = LocalScript.new # mixes in Dumpdb
    end
    subject{ @script }

    should have_cmeths :settings
    should have_imeths :settings, :dump_cmd, :restore_cmd
    should have_imeths :ssh?, :ssh_opts, :run

    should have_cmeths :ssh, :dump_file, :source, :target
    should have_imeths :ssh, :dump_file, :source, :target

    should have_cmeths :dump, :restore
    should have_imeths :dump_cmds, :restore_cmds, :copy_dump_cmd

    should have_imeths :before_run, :before_setup, :before_teardown
    should have_imeths :after_run,  :after_setup,  :after_teardown
    should have_imeths :before_dump, :before_copy_dump, :before_restore
    should have_imeths :after_dump,  :after_copy_dump,  :after_restore

    should "store its settings using ns-options" do
      assert_kind_of NsOptions::Namespace, subject.class.settings
      assert_same subject.class.settings, subject.settings
    end

    should "store off the settings for the script" do
      assert_kind_of Settings::Ssh,          subject.settings.ssh
      assert_kind_of Settings::DumpFile,     subject.settings.dump_file
      assert_kind_of Settings::SourceTarget, subject.settings.source
      assert_kind_of Settings::SourceTarget, subject.settings.target
      assert_kind_of Settings::CmdList,      subject.settings.dump_cmds
      assert_kind_of Settings::CmdList,      subject.settings.restore_cmds
    end

  end

  class CmdMethsTests < InitTests

    should "build dump command strings" do
      assert_equal 'echo local', subject.dump_cmd { "echo #{type}" }
    end

    should "build restore command strings" do
      assert_equal 'echo local', subject.restore_cmd { "echo #{type}" }
    end

  end

  class SshTests < InitTests

    should "know if its in ssh mode or not" do
      assert     RemoteScript.new.ssh?
      assert_not LocalScript.new.ssh?
    end

    should "know what ssh options to use" do
      exp_opts = "-o UserKnownHostsFile=/dev/null"\
                 " -o StrictHostKeyChecking=no"\
                 " -o ConnectTimeout=10"\

      assert_equal exp_opts, subject.ssh_opts
    end

  end

  class RunTests < InitTests
    setup do
      Dumpdb::FakeCmdRunner.reset
      @script = RunnerScript.new
    end
    teardown do
      Dumpdb::FakeCmdRunner.reset
    end

    should "run the script when `run` is called" do
      assert_empty Dumpdb::FakeCmdRunner.cmds
      @script.run(Dumpdb::FakeCmdRunner)

      assert_not_empty Dumpdb::FakeCmdRunner.cmds
      assert_equal 7, Dumpdb::FakeCmdRunner.cmds.size
      assert_equal "a restore cmd", Dumpdb::FakeCmdRunner.cmds[-3]
    end

  end

  class InheritedTests < InitTests
    desc "when inherited"
    setup do
      @a_remote_script     = RemoteScript.new
      @a_sub_remote_script = Class.new(RemoteScript).new
    end

    should "pass its definition values to any subclass" do
      assert_equal @a_remote_script.ssh, @a_sub_remote_script.ssh
    end

  end

end
