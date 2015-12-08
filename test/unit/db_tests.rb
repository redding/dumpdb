require 'assert'
require 'dumpdb/db'

class Dumpdb::Db

  class UnitTests < Assert::Context
    desc "Dumpdb::Db"
    setup do
      @db_class = Dumpdb::Db
    end
    subject{ @db_class }

    should "know its default value" do
      assert_equal '', DEFAULT_VALUE
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @dump_file_name = Factory.file_name
      @host           = Factory.string
      @port           = Factory.integer
      @user           = Factory.string
      @pw             = Factory.string
      @db_name        = Factory.string
      @output_root    = Factory.dir_path
      @custom_value   = Factory.string

      @current_time = Factory.time
      Assert.stub(Time, :now){ @current_time }

      @db = @db_class.new(@dump_file_name, {
        :host         => @host,
        :port         => @port,
        :user         => @user,
        :pw           => @pw,
        :db           => @db_name,
        :output_root  => @output_root,
        :custom_value => @custom_value
      })
    end
    subject { @db }

    should have_imeths :host, :port, :user, :pw, :db
    should have_imeths :output_root, :output_dir, :dump_file
    should have_imeths :to_hash

    should "know its attributes" do
      assert_equal @host,        subject.host
      assert_equal @port,        subject.port
      assert_equal @user,        subject.user
      assert_equal @pw,          subject.pw
      assert_equal @db_name,     subject.db
      assert_equal @output_root, subject.output_root
      exp = File.join(@output_root, "#{@host}__#{@db_name}__#{@current_time.to_f}")
      assert_equal exp, subject.output_dir
      exp = File.join(subject.output_dir, @dump_file_name)
      assert_equal exp, subject.dump_file
    end

    should "allow custom attributes" do
      assert_true subject.respond_to?(:custom_value)
      assert_equal @custom_value, subject.custom_value
    end

    should "default its attributes" do
      db = @db_class.new

      assert_equal DEFAULT_VALUE, db.host
      assert_equal DEFAULT_VALUE, db.port
      assert_equal DEFAULT_VALUE, db.user
      assert_equal DEFAULT_VALUE, db.pw
      assert_equal DEFAULT_VALUE, db.db
      assert_equal DEFAULT_VALUE, db.output_root
      assert_equal @current_time.to_f.to_s, db.output_dir
      exp = File.join(db.output_dir, 'dump.output')
      assert_equal exp, db.dump_file
    end

  end

end
