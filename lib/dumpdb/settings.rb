require 'dumpdb/db'

module Dumpdb::Settings

  class Base

    attr_reader :proc

    def initialize(proc=nil)
      @proc = proc.kind_of?(::Proc) ? proc : Proc.new { proc }
    end

    def value(script)
      script.instance_eval &@proc
    end

  end

  class Ssh < Base; end

  class Databases < Base

    def value(script)
      val = super
      val.kind_of?(::String) ? load_yaml(val) : val
    end

    private

    def load_yaml(file_path)
      YAML.load(File.read(File.expand_path(file_path)))
    end
  end

  class DumpFile < Base; end

  class SourceTarget < Base

    def value(script)
      val = super
      val.kind_of?(Dumpdb::Db) ? val : Dumpdb::Db.new(script.dump_file, val)
    end

  end

  class Cmd < Base

    def value(script, placeholder_vals)
      hsub(super(script), placeholder_vals)
    end

    private

    def hsub(string, hash)
      hash.inject(string) {|new_str, (k, v)| new_str.gsub(":#{k}", v.to_s)}
    end

  end

  class DumpCmd < Cmd

    def value(script, placeholder_vals={})
      val = super(script, script.source.to_hash.merge(placeholder_vals))
      if script.ssh?
        val = val.gsub("\\", "\\\\\\").gsub('"', '\"')
        val = "ssh -A #{script.ssh_opts} #{script.ssh} \"#{val}\""
      end
      val
    end

  end

  class RestoreCmd < Cmd

    def value(script, placeholder_vals={})
      super(script, script.target.to_hash.merge(placeholder_vals))
    end

  end

  class CopyDumpCmd < Cmd

    def value(script)
      if script.ssh?
        "sftp #{script.ssh_opts} #{script.ssh}:#{script.source.dump_file} #{script.target.dump_file}"
      else
        "cp #{script.source.dump_file} #{script.target.dump_file}"
      end
    end

  end

  class CmdList < ::Array

    def value(script, placeholder_vals={})
      self.map{|cmd| cmd.value(script, placeholder_vals)}
    end

  end

end
