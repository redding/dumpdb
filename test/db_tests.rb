require 'assert'
require 'ostruct'

module Dumpdb

  class DbTests < Assert::Context
    desc "the Db helper class"
    setup do
      @db = Db.new(nil)#(:host => 'h', :user => 'u', :pw => 'p', :db => 'd')
    end
    subject { @db }

    should have_imeths :host, :user, :pw, :db, :output_root, :output_dir, :dump_file

    should "default its values" do
      [:host, :user, :pw, :db, :output_root].each do |val|
        assert_equal '', subject.send(val)
      end
      assert_match '____',        subject.output_dir
      assert_match 'dump.output', subject.dump_file
    end

    should "set values" do
      db = Db.new('dump.file', :host => 'h', :db => 'd', :something => 'else')

      assert_equal 'h',         db.host
      assert_equal 'd',         db.db
      assert_match 'h__d__',    db.output_dir
      assert_match 'dump.file', db.dump_file
    end
  end

end
