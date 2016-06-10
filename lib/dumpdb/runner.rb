require 'dumpdb/settings'

module Dumpdb

  class Runner

    attr_reader :script, :cmd_runner

    def initialize(script, opts={})
      @script     = script
      @cmd_runner = opts[:cmd_runner] || scmd_cmd_runner
    end

    def run
      run_callback 'before_run'
      run_callback 'before_setup'
      run_setup

      begin
        run_callback 'after_setup'
        [:dump, :copy_dump, :restore].each{ |phase_name| run_phase phase_name }
      ensure
        run_phase 'teardown'
        run_callback 'after_run'
      end
    end

    private

    def run_setup
      run_cmd(@script.dump_cmd{ "mkdir -p #{source.output_dir}" })
      run_cmd(@script.restore_cmd{ "mkdir -p #{target.output_dir}" })
    end

    def run_dump
      @script.dump_cmds.each{ |cmd| run_cmd(cmd) }
    end

    def run_copy_dump
      run_cmd @script.copy_dump_cmd
    end

    def run_restore
      @script.restore_cmds.each{ |cmd| run_cmd(cmd) }
    end

    def run_teardown
      run_cmd(@script.dump_cmd{ "rm -rf #{source.output_dir}" })
      run_cmd(@script.restore_cmd{ "rm -rf #{target.output_dir}" })
    end

    def run_phase(phase_name)
      run_callback "before_#{phase_name}"
      self.send("run_#{phase_name}")
      run_callback "after_#{phase_name}"
    end

    def run_cmd(cmd_str)
      cmd_obj = @cmd_runner.new(cmd_str)
      run_callback('before_cmd_run', cmd_obj)
      cmd_obj.run!
      run_callback('after_cmd_run', cmd_obj)
    end

    def run_callback(meth, *args)
      @script.send(meth.to_s, *args)
    end

    def scmd_cmd_runner
      require 'scmd'
      Scmd
    end

  end

end
