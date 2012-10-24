require 'dumpdb/settings'

module Dumpdb
  class Runner

    attr_reader :script, :cmd_runner

    def initialize(script, opts={})
      @script = script
      @cmd_runner = opts[:cmd_runner] || scmd_cmd_runner
    end

    def run
      run_callback 'before_run'

      [:setup, :dump, :copy_dump, :restore, :teardown].each do |phase|
        run_callback "before_#{phase}"
        self.send("run_#{phase}")
        run_callback "after_#{phase}"
      end

      run_callback 'after_run'
    end

    protected

    def run_setup
      run_cmd(@script.dump_cmd    { "mkdir -p #{source.output_dir}"  })
      run_cmd(@script.restore_cmd { "mkdir -p #{target.output_dir}"  })
    end

    def run_dump
      @script.dump_cmds.each{|cmd| run_cmd(cmd)}
    end

    def run_copy_dump
      run_cmd @script.copy_dump_cmd
    end

    def run_restore
      @script.restore_cmds.each{|cmd| run_cmd(cmd)}
    end

    def run_teardown
      run_cmd(@script.dump_cmd    { "rm -rf #{source.output_dir}" })
      run_cmd(@script.restore_cmd { "rm -rf #{target.output_dir}" })
    end

    private

    def run_cmd(cmd)
      @cmd_runner.new(cmd).run!
    end

    def run_callback(meth)
      @script.send(meth.to_s)
    end

    def scmd_cmd_runner
      require 'scmd'
      Scmd
    end

  end
end
