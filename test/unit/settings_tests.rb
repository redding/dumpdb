require 'assert'
require 'dumpdb/settings'

require 'dumpdb/db'
require 'test/support/test_scripts'

module Dumpdb::Settings

  class UnitTests < Assert::Context
    desc "Dumpdb::Settings"
    setup do
      @script = LocalScript.new
    end

  end

  class BaseTests < UnitTests
    desc "Base"
    setup do
      @setting = Base.new
    end
    subject{ @setting }

    should have_readers :proc
    should have_imeths :value

    should "know its proc" do
      assert_kind_of ::Proc, subject.proc
      assert_nil subject.proc.call
    end

    should "instance eval its proc in the scope of a script to return a value" do
      setting = Base.new(Proc.new{ "something: #{type}" })

      assert_equal "local",            @script.type
      assert_equal "something: local", setting.value(@script)
    end

  end

  class SshTests < UnitTests
    desc "Ssh"

    should "be a Base setting" do
      assert_true Ssh < Base
    end

  end

  class DumpFileTests < UnitTests
    desc "DumpFile"

    should "be a Base setting" do
      assert_true DumpFile < Base
    end

  end

  class SourceTargetTests < UnitTests
    desc "SourceTarget"

    should "be a Base setting" do
      assert_true SourceTarget < Base
    end

    should "have a Db value built from a hash" do
      from_hash = { 'host' => 'from_hash' }
      db = SourceTarget.new(from_hash).value(@script)

      assert_kind_of Dumpdb::Db, db
      assert_equal 'from_hash', db.host
    end

  end

  class CmdTests < UnitTests
    desc "Cmd"

    should "be a Base setting" do
      assert_true Cmd < Base
    end

    should "eval and apply any placeholders to the cmd string" do
      cmd_str = Proc.new{ "this is the #{type} db: :db" }
      cmd_val = Cmd.new(cmd_str).value(@script, @script.source.to_hash)
      assert_equal "this is the local db: devdb", cmd_val
    end

  end

  class DumpCmdTests < UnitTests
    desc "DumpCmd"

    should "be a Cmd setting" do
      assert_true DumpCmd < Cmd
    end

    should "eval and apply any source placeholders to the cmd string" do
      cmd_str = Proc.new{ "this is the #{type} db: :db" }
      cmd_val = DumpCmd.new(cmd_str).value(@script)
      assert_equal "this is the local db: devdb", cmd_val
    end

    should "not escape any double-quotes in the cmds" do
      orig_cmd = "do_something --value=\"a_val\""
      cmd_val  = DumpCmd.new(Proc.new{ orig_cmd }).value(@script)
      assert_equal orig_cmd, cmd_val
    end

    should "not escape any backslashes in the cmds" do
      orig_cmd = "do \\something"
      cmd_val  = DumpCmd.new(Proc.new{ orig_cmd }).value(@script)
      assert_equal orig_cmd, cmd_val
    end

  end

  class RestoreCmdTests < UnitTests
    desc "RestoreCmd"

    should "be a Cmd setting" do
      assert_true RestoreCmd < Cmd
    end

    should "eval and apply any target placeholders to the cmd string" do
      cmd_str = Proc.new{ "this is the #{type} db: :db" }
      cmd_val = RestoreCmd.new(cmd_str).value(@script)
      assert_equal "this is the local db: testdb", cmd_val
    end

  end

  class CopyDumpCmdTests < UnitTests
    desc "CopyDumpCmd"

    should "be a Cmd setting" do
      assert_true CopyDumpCmd < Cmd
    end

    should "be a copy cmd for non-ssh scripts" do
      exp = "cp #{@script.source.dump_file} #{@script.target.dump_file}"
      assert_equal exp, @script.copy_dump_cmd
    end

    should "be an sftp cmd for ssh scripts" do
      script = RemoteScript.new
      exp = "sftp #{script.ssh_opts} #{script.ssh}:#{script.source.dump_file} " \
            "#{script.target.dump_file}"
      assert_equal exp, script.copy_dump_cmd
    end

  end

  class CmdListTests < UnitTests
    desc "CmdList"
    setup do
      @cmds = [
        Cmd.new(Proc.new{ "this is the #{type} target db: :db" }),
        Cmd.new(Proc.new{ "this is the #{type} target host: :host" })
      ]
      @exp_val_cmds = [
        "this is the local target db: testdb",
        "this is the local target host: testhost"
      ]
    end

    should "be an Array" do
      assert_kind_of ::Array, CmdList.new
    end

    should "return the commands, eval'd and placeholders applied" do
      val_cmds = CmdList.new(@cmds).value(@script, @script.target.to_hash)
      assert_equal @exp_val_cmds, val_cmds
    end

  end

  class RemoteDumpCmdTests < UnitTests
    desc "using ssh"
    setup do
      @script  = RemoteScript.new
      @cmd_str = Proc.new{ "echo hello" }
    end

    should "build the cmds to run remotely using ssh" do
      exp = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"echo hello\""
      assert_equal exp, DumpCmd.new(@cmd_str).value(@script)
    end

    should "escape any double-quotes in the cmds" do
      orig_cmd    = "do_something --value=\"a_val\""
      exp_esc_cmd = "do_something --value=\\\"a_val\\\""

      exp = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"#{exp_esc_cmd}\""
      assert_equal exp, DumpCmd.new(Proc.new{ orig_cmd }).value(@script)
    end

    should "escape any backslashes in the cmds" do
      orig_cmd    = "do \\something"
      exp_esc_cmd = "do \\\\something"

      exp = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"#{exp_esc_cmd}\""
      assert_equal exp, DumpCmd.new(Proc.new{ orig_cmd }).value(@script)
    end

    should "escape any backslashes before double-quotes in the cmds" do
      orig_cmd    = "do \\something --value=\"a_val\""
      exp_esc_cmd = "do \\\\something --value=\\\"a_val\\\""

      exp = "ssh -A #{@script.ssh_opts} #{@script.ssh} \"#{exp_esc_cmd}\""
      assert_equal exp, DumpCmd.new(Proc.new{ orig_cmd }).value(@script)
    end

  end

end
