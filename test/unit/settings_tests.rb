require 'assert'
require 'test/support/test_scripts'
require 'dumpdb/settings'

module Dumpdb

  class SettingsTests < Assert::Context
    desc "the script settings"
    setup do
      @setting = Settings::Base.new
      @script = LocalScript.new
    end
    subject { @setting }

    should have_imeth :value
    should have_reader :proc

    should "know its value proc" do
      assert_kind_of ::Proc, subject.proc
      assert_nil subject.proc.call
    end

    should "instance eval its proc in the scope of a script to return a value" do
      setting = Settings::Base.new(Proc.new { "something: #{type}"})

      assert_equal "local", @script.type
      assert_equal "something: local", setting.value(@script)
    end

  end

  class SshSettingTests < SettingsTests
    desc "`ssh` setting"

    should "be available" do
      assert Settings::Ssh
    end

  end

  class DumpFileSettingTests < SettingsTests
    desc "`dump_file` setting"

    should "be available" do
      assert Settings::DumpFile
    end

  end

  class SourceTargetSettingTests < SettingsTests
    desc "`source` or `target` setting"
    setup do
      @from_hash = {'host' => 'from_hash'}
    end

    should "be available" do
      assert Settings::SourceTarget
    end

    should "come from a hash" do
      db = Settings::SourceTarget.new(@from_hash).value(@script)

      assert_kind_of Db, db
      assert_equal 'from_hash', db.host
    end

  end

  class CmdTests < SettingsTests
    desc "command helper class"
    setup do
      @cmd_str = Proc.new { "this is the #{type} db: :db" }
    end

    should "be available" do
      assert Settings::Cmd
    end

    should "eval and apply any placeholders to the cmd string" do
      cmd_val = Settings::Cmd.new(@cmd_str).value(@script, @script.source.to_hash)
      assert_equal "this is the local db: devdb", cmd_val
    end

  end

  class DumpCmdTests < CmdTests
    desc "for dump commands"

    should "eval and apply any source placeholders to the cmd string" do
      cmd_val = Settings::DumpCmd.new(@cmd_str).value(@script)
      assert_equal "this is the local db: devdb", cmd_val
    end

    should "not escape any double-quotes in the cmds" do
      orig_cmd    = "do_something --value=\"a_val\""
      cmd_val = Settings::DumpCmd.new(Proc.new { orig_cmd }).value(@script)

      assert_equal orig_cmd, cmd_val
    end

    should "not escape any backslashes in the cmds" do
      orig_cmd    = "do \\something"
      cmd_val = Settings::DumpCmd.new(Proc.new { orig_cmd }).value(@script)

      assert_equal orig_cmd, cmd_val
    end

  end

  class RemoteDumpCmdTests < DumpCmdTests
    desc "using ssh"
    setup do
      @script = RemoteScript.new
      @cmd_str = Proc.new { "echo hello" }
    end

    should "build the cmds to run remtoely using ssh" do
      exp_cmd_str = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"echo hello\""
      cmd_val = Settings::DumpCmd.new(@cmd_str).value(@script)

      assert_equal exp_cmd_str, cmd_val
    end

    should "escape any double-quotes in the cmds" do
      orig_cmd    = "do_something --value=\"a_val\""
      exp_esc_cmd = "do_something --value=\\\"a_val\\\""
      exp_cmd_str = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"#{exp_esc_cmd}\""
      cmd_val = Settings::DumpCmd.new(Proc.new { orig_cmd }).value(@script)

      assert_equal exp_cmd_str, cmd_val
    end

    should "escape any backslashes in the cmds" do
      orig_cmd    = "do \\something"
      exp_esc_cmd = "do \\\\something"
      exp_cmd_str = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"#{exp_esc_cmd}\""
      cmd_val = Settings::DumpCmd.new(Proc.new { orig_cmd }).value(@script)

      assert_equal exp_cmd_str, cmd_val
    end

    should "escape any backslashes before double-quotes in the cmds" do
      orig_cmd    = "do \\something --value=\"a_val\""
      exp_esc_cmd = "do \\\\something --value=\\\"a_val\\\""
      exp_cmd_str = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"#{exp_esc_cmd}\""
      cmd_val = Settings::DumpCmd.new(Proc.new { orig_cmd }).value(@script)

      assert_equal exp_cmd_str, cmd_val
    end

  end

  class RestoreCmdTests < CmdTests
    desc "for restore commands"

    should "eval and apply any target placeholders to the cmd string" do
      cmd_val = Settings::RestoreCmd.new(@cmd_str).value(@script)
      assert_equal "this is the local db: testdb", cmd_val
    end

  end

  class CopyDumpCmdTests < CmdTests

    should "be a copy cmd for non-ssh scripts" do
      script = @script
      exp_cmd = "cp #{script.source.dump_file} #{script.target.dump_file}"

      assert_equal exp_cmd, script.copy_dump_cmd
    end

    should "be an sftp cmd for ssh scripts" do
      script = RemoteScript.new
      exp_cmd = "sftp #{script.ssh_opts} #{script.ssh}:#{script.source.dump_file} #{script.target.dump_file}"

      assert_equal exp_cmd, script.copy_dump_cmd
    end

  end

  class CmdListTests < SettingsTests
    desc "command list helper class"
    setup do
      @cmds = [
        Settings::Cmd.new(Proc.new { "this is the #{type} target db: :db" }),
        Settings::Cmd.new(Proc.new { "this is the #{type} target host: :host" })
      ]
      @exp_val_cmds = [
        "this is the local target db: testdb",
        "this is the local target host: testhost"
      ]
    end

    should "be an Array" do
      assert_kind_of ::Array, Settings::CmdList.new
    end

    should "return the commands, eval'd and placeholders applied" do
      val_cmds = Settings::CmdList.new(@cmds).value(@script, @script.target.to_hash)
      assert_equal @exp_val_cmds, val_cmds
    end

  end


end
