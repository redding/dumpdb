module Dumpdb

  class Db

    DEFAULT_VALUE = ''.freeze

    def initialize(dump_file_name = nil, values = nil)
      dump_file_name = dump_file_name || 'dump.output'
      @values        = dumpdb_symbolize_keys(values)

      [:host, :port, :user, :pw, :db, :output_root].each do |key|
        @values[key] ||= DEFAULT_VALUE
      end

      @values[:output_dir] = dumpdb_build_output_dir(
        self.output_root,
        self.host,
        self.db
      )
      @values[:dump_file] = File.join(self.output_dir, dump_file_name)
    end

    def to_hash; @values; end

    def method_missing(meth, *args, &block)
      if @values.has_key?(meth.to_sym)
        @values[meth.to_sym]
      else
        super
      end
    end

    def respond_to?(meth)
      @values.has_key?(meth.to_sym) || super
    end

    private

    def dumpdb_build_output_dir(output_root, host, database)
      dir_name = dumpdb_build_output_dir_name(host, database)
      if output_root && !output_root.to_s.empty?
        File.join(output_root, dir_name)
      else
        dir_name
      end
    end

    def dumpdb_build_output_dir_name(host, database)
      [host, database, Time.now.to_f].map(&:to_s).reject(&:empty?).join("__")
    end

    def dumpdb_symbolize_keys(values)
      (values || {}).inject({}) do |h, (k, v)|
        h.merge(k.to_sym => v)
      end
    end

  end

end
