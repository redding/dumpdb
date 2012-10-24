require 'ns-options'

require 'dumpdb/settings'
require 'dumpdb/db'
require 'dumpdb/runner'

module Dumpdb

  class BadDatabaseName < RuntimeError; end

  module Script

    def self.included(receiver)
      receiver.class_eval do
        include NsOptions
        options :settings do
          option 'ssh',          Settings::Ssh,          :default => ''
          option 'databases',    Settings::Databases,    :default => {}
          option 'dump_file',    Settings::DumpFile,     :default => ''
          option 'source',       Settings::SourceTarget, :default => {}
          option 'target',       Settings::SourceTarget, :default => {}
          option 'dump_cmds',    Settings::CmdList,      :default => []
          option 'restore_cmds', Settings::CmdList,      :default => []
        end

        # TODO: can move this to SettingsMethods if ns-option uses anonymous modules
        def settings; self.class.settings; end

        extend  SettingsDslMethods
        include SettingsMethods

      end
    end

    module SettingsDslMethods

      def ssh(&block);       settings.ssh       = Settings::Ssh.new(block);          end
      def databases(&block); settings.databases = Settings::Databases.new(block);    end
      def dump_file(&block); settings.dump_file = Settings::DumpFile.new(block);     end
      def source(&block);    settings.source    = Settings::SourceTarget.new(block); end
      def target(&block);    settings.target    = Settings::SourceTarget.new(block); end

      def dump(&block);    settings.dump_cmds    << Settings::DumpCmd.new(block);    end
      def restore(&block); settings.restore_cmds << Settings::RestoreCmd.new(block); end

    end

    module SettingsMethods

      def ssh;       @ssh       ||= settings.ssh.value(self);       end
      def databases; @databases ||= settings.databases.value(self); end
      def dump_file; @dump_file ||= settings.dump_file.value(self); end
      def source;    @source    ||= settings.source.value(self);    end
      def target;    @target    ||= settings.target.value(self);    end

      def dump_cmds;     @dump_cmds     ||= settings.dump_cmds.value(self);        end
      def restore_cmds;  @restore_cmds  ||= settings.restore_cmds.value(self);     end
      def copy_dump_cmd; @copy_dump_cmd ||= Settings::CopyDumpCmd.new.value(self); end

    end

    def db(database_name, other_vals=nil)
      if (db_vals = self.databases[database_name]).nil?
        raise BadDatabaseName, "no database named `#{database_name}'."
      end
      Db.new(self.dump_file, db_vals.merge(other_vals || {}))
    end

    def dump_cmd(&block);   Settings::DumpCmd.new(block).value(self);    end
    def restore_cmd(&block) Settings::RestoreCmd.new(block).value(self); end

    def ssh?
      self.ssh && !self.ssh.empty?
    end

    def ssh_opts
      "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=10"
    end

    def run(cmd_runner=nil)
      Runner.new(self, :cmd_runner => cmd_runner).run
    end

    # Callbacks

    def before_run;       end
    def after_run;        end
    def before_setup;     end
    def after_setup;      end
    def before_dump;      end
    def after_dump;       end
    def before_copy_dump; end
    def after_copy_dump;  end
    def before_restore;   end
    def after_restore;    end
    def before_teardown;  end
    def after_teardown;   end

  end

end
