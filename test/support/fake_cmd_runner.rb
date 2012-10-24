module Dumpdb

  class FakeCmdRunner

    def self.cmds
      @@cmds ||= []
      @@cmds
    end

    def self.reset
      @@cmds = []
    end

    def initialize(cmd)
      @cmd = cmd
    end

    def run!
      FakeCmdRunner.cmds << @cmd
    end

  end

end
