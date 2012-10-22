# Dumpdb

Dump and restore your databases.

## Installation

Add this line to your application's Gemfile:

    gem 'dumpdb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumpdb

## Usage

```ruby
require 'dumpdb'

class MysqlFullRestore
  include Dumpdb::Script

  databases { '/path/to/database.yml'}
  dump_file  { "dump.bz2" }
  source { db('production',  :output => '/some/source/dir') }
  target { db('development', :output => '/some/target/dir') }

  dump    { "mysqldump -u :user -p\":pw\" :db | bzip2 > :dump_file" }
  restore { "mysqladmin -u :user -p\":pw\" -f -b DROP :db; true" }
  restore { "mysqladmin -u :user -p\":pw\" -f CREATE :db" }
  restore { "bunzip2 -c :dump_file | mysql -u :user -p\":pw\" :db" }

end
```

Dumpdb provides a framework for scripting database backups and restores.  You configure your source and target db settings.  You define the set of commands needed for your script to dump the (local or remote) source database and optionally restore the dump to the (local) target database.

### Running

Once you have created an instance of your script with its database settings you can run it.

```ruby
MysqlFullRestore.new.run
```

Dumpdb runs the dump commands using source settings and runs the restore commands using target settings.  By default, Dumpdb assumes both the dump and restore commands are to be run on the local system.

### Remote dumps

To run your dump commands on a remote server, specify the optional `ssh` setting.

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  ssh { 'user@host' }

  # ...
end
```

This tells Dumpdb to run the dump commands using ssh on a remote host and to download the dump file using sftp.

## Define your script

Every Dumpdb script assumes there are two types of commands involved: dump commands that run using source settings and restore commands that run using target settings.  The dump commands should produce a single "dump file" (typically a compressed file or tar).  The restore commands restore the local db from the dump file.

### The Dump File

You specify the name of the dump file using the `dump_file` setting

```ruby
# ...
dump_file { "dump.bz2" }
#...
```

This tells Dumpdb what file is being generated by the dump and will be used in the restore.  The dump commands should produce it.  The restore commands should use it.

### Dump commands

Dump commands are system commands that should produce the dump file.

```ruby
# ...
dump { "mysqldump -u :user -p :pw :db | bzip2 > :dump_file" }
#...
```

### Restore commands

Restore commands are system commands that should restore the local db from the dump file.

```ruby
# ...
restore { "mysqladmin -u :user :pw -f -b DROP :db; true" }   # drop the local db, whether it exists or not
restore { "mysqladmin -u :user :pw -f CREATE :db" }          # recreate the local db
restore { "bunzip2 -c :dump_file | mysql -u :user :pw :db" } # unzip the dump file and apply it to the db
#...
```

### Command Placeholders

Dump and restore commands are templated.  You define the command with placeholders and appropriate setting values are substituted in when the script is run.

Command placeholders should correspond with keys in the source or target settings.  Dump commands use the source settings and restore commands use the target settings.

### Special Placeholders

There are two special placeholders that are added to the source and target settings automatically:

* `:output`    - the dir name the dump file is written to - unique to each script instance.
* `:dump_file` - the output path of the dump file - uses the :output setting

You should at least use the `:dump_file` placeholder in your dump and restore commands to ensure proper dump handling and usage.

```ruby
dump_file { "dump.bz2" }

dump    { "mysqldump :db | bzip2 > :dump_file" }
restore { "bunzip2 -c :dump_file | mysql :db" }
```

## Source / Target settings

A Dumpdb script needs to be told about its source and target settings.  You tell it these when you define your script:

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  source do
    { 'user' => 'something',
      'pw'   => 'secret',
      'db'   => 'something_production',
      'something' => 'else'
    }
  end

  target do
    { 'user' => 'root',
      'pw'   => 'supersecret',
      'db'   => 'something_development'
    }
  end

  # ...
end
```

Any settings keys can be used as command placeholders in dump and restore commands.

### Lookup settings from YAML

Since many ORMs allow you to configure db connections using yaml files, Dumpdb supports specifying your databases from a yaml file.

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  databases { '/path/to/database.yml' }

  # ...
end
```

Now you can lookup your source and target settings using the `db` method.

```ruby
databases { '/path/to/database.yml' }
source { db('production') }
target { db('development') }
```

You can merge in additional settings by passing them to the `db` command:

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  databases { '/path/to/database.yml' }
  source { db('produciton', :something => 'else') }

  # ...
end
```

**Note:** When reading settings from yaml files, Dumpdb takes common keys like 'hostname', 'username', 'password', and 'database' and converts them to the more succinct 'host', 'user', 'pw', and 'db'.  This is not the case if you manually specify your settings.

### Building Commands

As you may have noticed, the script DSL settings methods all take a proc as their argument.  This is because the procs are lazy-eval'd in the scope of the script instance.  This allows you to use interpolation to help build commands with dynamic data.

Take this example where you want your dump script to honor ignored tables.

```ruby
require 'dumpdb'

class MysqlIgnoredTablesRestore
  include Dumpdb::Script

  # ...
  dump { "mysqldump -u :user -p :pw :db #{ignored_tables} | bzip2 > :dump_file" }
  # ...

  def initialize(opts={})
    opts[:ignored_tables] ||= []
    @opts = opts
  end

  def ignored_tables
    @opts[:ignored_tables].collect {|t| "--ignore-table=#{source.db}.#{t}"}.join(' ')
  end
end
```

## Examples

See `examples/` dir.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
