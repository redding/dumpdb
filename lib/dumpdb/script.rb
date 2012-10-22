module Dumpdb

  module Script

    def self.included(receiver)
      receiver.class_eval do
        extend SettingsDslMethods
        include SettingsMethods
      end
    end

    module SettingsDslMethods

      def ssh; end
      def databases; end
      def dump_file; end
      def source; end
      def target; end
      def dump; end
      def restore; end

    end

    module SettingsMethods

      def ssh; end
      def databases; end
      def dump_file; end
      def source; end
      def target; end
      def dump_cmds; end
      def restore_cmds; end

    end

    def run; end

  end

end
