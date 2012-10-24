require 'assert'

module Dumpdb

  class ScriptTests < Assert::Context
    desc "the script mixin"
    setup do
      # TODO: fix ns-options so you can set this to LocalScript and it won't fail
      @script = LocalScript.new
    end
    subject { @script }

    should have_cmeths :settings
    should have_imeths :settings, :db, :ssh?, :ssh_opts, :run

    should have_cmeths :ssh, :databases, :dump_file, :source, :target
    should have_imeths :ssh, :databases, :dump_file, :source, :target

    should have_cmeths :dump, :restore
    should have_imeths :dump_cmds, :restore_cmds, :copy_dump_cmd

    should "store its settings using ns-options" do
      assert_kind_of NsOptions::Namespace, subject.class.settings
      assert_same subject.class.settings, subject.settings
    end

    should "store off the settings for the script" do
      assert_kind_of Settings::Ssh,          subject.settings.ssh
      assert_kind_of Settings::Databases,    subject.settings.databases
      assert_kind_of Settings::DumpFile,     subject.settings.dump_file
      assert_kind_of Settings::SourceTarget, subject.settings.source
      assert_kind_of Settings::SourceTarget, subject.settings.target
      assert_kind_of Settings::CmdList,      subject.settings.dump_cmds
      assert_kind_of Settings::CmdList,      subject.settings.restore_cmds
    end

  end

  class DbMethTests < ScriptTests
    desc "`db' method"
    setup do
      @script = LocalScript.new
    end

    should "build a Db based on the named database values" do
      assert_kind_of Db, subject.target
      assert_equal 'testhost', subject.target.host
    end

    should "build a Db based on the named database values plus additional values" do
      assert_kind_of Db, subject.source
      assert_equal 'devhost', subject.source.host
      assert_equal 'value', subject.source.another
    end

    should "complain if looking up a db not in the `databases` collection" do
      assert_raises BadDatabaseName do
        subject.db('does_not_exist')
      end
    end

  end

  class SshTests < ScriptTests

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

end
