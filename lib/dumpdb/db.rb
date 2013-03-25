module Dumpdb

  class Db

    def initialize(dump_file_name, values=nil)
      @dump_file_name = dump_file_name || 'dump.output'
      @values = (values || {}).inject({}) do |vals, (k, v)|
        # stringify keys
        vals.merge(k.to_s => v)
      end

      @values['host']        ||= (@values['hostname'] || '')
      @values['user']        ||= (@values['username'] || '')
      @values['pw']          ||= (@values['password'] || '')
      @values['db']          ||= (@values['database'] || '')
      @values['output_root'] ||= ''

      @values['output_dir'] = output_dir(self.output_root, "#{self.host}__#{self.db}")
      @values['dump_file']  = File.join(self.output_dir, @dump_file_name)
    end

    def to_hash; @values; end

    def method_missing(meth, *args, &block)
      if @values.has_key?(meth.to_s)
        @values[meth.to_s]
      else
        super
      end
    end

    def respond_to?(meth)
      @values.has_key?(meth.to_s) || super
    end

    private

    def output_dir(root, name)
      name_time = "#{name}__#{Time.now.to_f}"
      root && !root.empty? ? File.join(root, name_time) : name_time
    end

  end

end
