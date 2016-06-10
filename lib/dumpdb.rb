require 'much-plugin'
require 'dumpdb/version'
require 'dumpdb/settings'
require 'dumpdb/db'
require 'dumpdb/runner'

module Dumpdb
  include MuchPlugin

  plugin_included do
    extend  ClassMethods
    include InstanceMethods

    def self.inherited(subclass)
      subclass.settings = self.settings
    end

  end

  module ClassMethods

    def ssh(&block);       settings[:ssh]       = Settings::Ssh.new(block);          end
    def dump_file(&block); settings[:dump_file] = Settings::DumpFile.new(block);     end
    def source(&block);    settings[:source]    = Settings::SourceTarget.new(block); end
    def target(&block);    settings[:target]    = Settings::SourceTarget.new(block); end

    def dump(&block);    settings[:dump_cmds]    << Settings::DumpCmd.new(block);    end
    def restore(&block); settings[:restore_cmds] << Settings::RestoreCmd.new(block); end

    def settings
      @settings ||= {
        :ssh          => Settings::Ssh.new(''),
        :dump_file    => Settings::DumpFile.new(''),
        :source       => Settings::SourceTarget.new({}),
        :target       => Settings::SourceTarget.new({}),
        :dump_cmds    => Settings::CmdList.new([]),
        :restore_cmds => Settings::CmdList.new([])
      }
    end

    def settings=(value); @settings = value; end

  end

  module InstanceMethods

    def ssh;       @ssh       ||= settings[:ssh].value(self);       end
    def dump_file; @dump_file ||= settings[:dump_file].value(self); end
    def source;    @source    ||= settings[:source].value(self);    end
    def target;    @target    ||= settings[:target].value(self);    end

    def dump_cmds;     @dump_cmds     ||= settings[:dump_cmds].value(self);      end
    def restore_cmds;  @restore_cmds  ||= settings[:restore_cmds].value(self);   end
    def copy_dump_cmd; @copy_dump_cmd ||= Settings::CopyDumpCmd.new.value(self); end

    def settings; self.class.settings; end

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

  def before_run(*args);       end
  def after_run(*args);        end
  def before_setup(*args);     end
  def after_setup(*args);      end
  def before_dump(*args);      end
  def after_dump(*args);       end
  def before_copy_dump(*args); end
  def after_copy_dump(*args);  end
  def before_restore(*args);   end
  def after_restore(*args);    end
  def before_teardown(*args);  end
  def after_teardown(*args);   end
  def before_cmd_run(*args);   end
  def after_cmd_run(*args);    end

  BadDatabaseName = Class.new(RuntimeError)

end
