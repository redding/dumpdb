# Dumpdb

Dump, fetch, and restore your databases.

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
  source { db('production',  :output => '/some/source/dir') }
  target { db('development', :output => '/some/target/dir') }

  dump    { "mysqldump -u :user -p :pw :db | bzip2 > :fetch" }
  fetch   { "data.bz2" }
  restore { "mysqladmin -u :user :pw -f -b DROP :db; true" }
  restore { "mysqladmin -u :user :pw -f CREATE :db" }
  restore { "bunzip2 -c :fetch | mysql -u :user :pw :db" }

end
```

Dumpdb provides a framework for scripting database backups and restores.  You configure your source and target db settings.  You define the set of commands needed for your script to dump the remote (source) databases, fetch the dumps, and optionally restore the dump to your local (target) database.

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

This tells Dumpdb to run the dump commands using ssh on a remote host and to fetch the dumps using sftp.

## Define your script

Every Dumpdb script assumes there are two types of commands involved: dump commands that run using source settings and restore commands that run using target settings.  The dump commands should produce a single "fetch file" (typically a compressed dump file or archive file).  The restore commands restore the local db from the fetch file.

### The Fetch file

You specify the name of the fetch file using the `fetch` setting

```ruby
# ...
fetch { "data.bz2" }
#...
```

This tells Dumpdb what file on the remote server to expect and copy local.  The dump commands should produce it.  This also tells the restore commands the file to expect and restore from.

### Dump commands

Dump commands are system commands that should produce the fetch file.

```ruby
# ...
dump { "mysqldump -u :user -p :pw :db | bzip2 > :fetch" }
#...
```

### Restore commands

Restore commands are system commands that should restore the local db from the fetch file.

```ruby
# ...
restore { "mysqladmin -u :user :pw -f -b DROP :db; true" }  # drop the local db, whether it exists or not
restore { "mysqladmin -u :user :pw -f CREATE :db" }         # recreate the local db
restore { "bunzip2 -c :fetch | mysql -u :user :pw :db" }    # unzip the fetch file and apply it to the db
#...
```

### Command Placeholders

Dump and restore commands are templated.  You define the command with placeholders and appropriate setting values are substituted in when the script is run.

Command placeholders should correspond with keys in the source or target settings.  Dump commands use the source settings and restore commands use the target settings.

### Special Placeholders

There are two special placeholders that are added to the source and target settings automatically:

* `:output` - the dir name the fetch file is written to - unique to each script instance.
* `:fetch`  - the output path of the fetch file - uses the :output setting

You should at least use the `:fetch` placeholder in your dump and restore commands to ensure proper dump fetching and usage.

```ruby
dump    { "mysqldump :db | bzip2 > :fetch" }
fetch   { "data.bz2" }
restore { "bunzip2 -c :fetch | mysql :db" }
```

## Source / Target settings

A Dumpdb script needs to be told about its source and target settings.  You tell it these when you define your script:

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  source do
    { 'user' => 'something',
      'pw'   => 'secret',
      'db'   => 'something_production'
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

As you may have noticed, the script DSL methods all take a proc as their argument.  This is because the procs are lazy-eval'd in the scope of the script instance.  This allows you to use interpolation to help build commands with dynamic data.

Take this example where you want your dump script to honor ignored tables.

```ruby
require 'dumpdb'

class MysqlIgnoredTablesRestore
  include Dumpdb::Script

  # ...
  dump { "mysqldump -u :user -p :pw :db #{ignored_tables} | bzip2 > :fetch" }
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
