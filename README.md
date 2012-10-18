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

Dumpdb provides a framework for scripting database backups and restores.  You configure your source and target db settings.  You define the set of commands needed for your script to dump the remote (source) databases, fetch the dumps, and optionally restore the dump to your local (target) database.

```ruby
require 'dumpdb'

class MysqlFullRestore
  include Dumpdb::Script

  databases { '/path/to/database.yml'}

  dump     { "mysqldump -u :user -p :pw :db | bzip2 > :fetch" }
  fetch    { "data.bz2" }
  restore  { "mysqladmin -u :user :pw -f -b DROP :db; true" }
  restore  { "mysqladmin -u :user :pw -f CREATE :db" }
  restore  { "bunzip2 -c :fetch | mysql -u :user :pw :db" }

end
```

### Run the script

Once you have created an instance of your script with its database settings you can run it.  When running a script, you need to tell Dumpdb the source and the target databases

```ruby
script.run do |runner|
  # ...
  runner.source('production', '/some/remote/dir')
  runner.target('development', '/some/local/dir')
end
```

Both `source` and `target` take two params: the db settings name, and the output path (on the remote server for source and local for target) available to the dump.  This path is where the fetch file will be written.

The Dumpdb Runner runs the dump commands on the remote source host and runs the restore commmands locally.  It assumes the restore commands are suitable to be run locally by you.  For the dump commands, Dumpdb will run them using SSH.  You need to tell Dumpdb how to ssh into the remote host as.

```ruby
script.run do |runner|
  runner.ssh_user('user')
  # ...
end
```

## Setup the databases

A Dumpdb script needs to be told about its databases.  Specifically, it needs to know the host, user, pw, and db name for each.

You tell it these when you define your script:

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  databases do
    { 'production' => {
        'host' => 'host1.example.com', 'user' => 'host1', 'pw' => 'secret', 'db' => 'something_production'
      },
      'development' => {
        'host' => 'localhost', 'user' => 'root', 'pw' => 'supersecret', 'db' => 'something_development'
      }
    }
  end

  # ...
end
```

Alternatively, Dumpdb recognizes yaml configs:

```ruby
class MysqlFullRestore
  include Dumpdb::Script

  databases { '/path/to/database.yml'}

  # ...
end
```

## Define your script

Every Dumpdb script assumes there are two types of commands involved: dump commands that run on the remote source and restore commands that run locally.  The dump commands should produce a single "fetch file" (typically a compressed dump file or archive file).  The restore commands restore the local db from the fetch file.

### The Fetch file

You specify the name of the fetch file using the `fetch` setting

```ruby
# ...
fetch   { "data.bz2" }
#...
```

This tells Dumpdb what file on the remote server to expect and copy local.  The dump commands should produce it.  This also tells the restore commands the file to expect and restore from.

### Dump commands

Dump commands are system commands that are run on the remote server.  They have one requirement: they should produce the fetch file.

```ruby
# ...
dump    { "mysqldump -u :user -p :pw :db | bzip2 > :fetch" }
#...
```

Dump commands are templated.  You define the command with placeholders and appropriate values are substituted in at runtime.

Dump command placeholders:

* `:host`  - source host setting
* `:user`  - source user
* `:pw`    - source pw
* `:db`    - source db
* `:out`   - the path where output can be written on the remote server
* `:fetch` - the path to the fetch file on the remote server

### Restore commands

Restore commands are system commands that are run locally to reset and restore the local db from the fetch file.

```ruby
# ...
restore { "mysqladmin -u :user :pw -f -b DROP :db; true" }  # drop the local db, whether it exists or not
restore { "mysqladmin -u :user :pw -f CREATE :db" }         # recreate the local db
restore { "bunzip2 -c :fetch | mysql -u :user :pw :db" }    # unzip the fetch file and apply it to the db
#...
```

Restore commands are templated.  You define the command with placeholders and appropriate values are substituted in at runtime.

Dump command placeholders:

* `:host`  - target host setting
* `:user`  - target user
* `:pw`    - target pw
* `:db`    - target db
* `:out`   - the local path where output can be written
* `:fetch` - the local path to the fetch file


### Building Commands

As you may have noticed, the `dump`, `fetch`, and `restore` settings all take a proc as their argument.  This is because the procs are lazy-eval'd in the scope of the script instance.  This allows you to use interpolation to help build commands with dynamic data.  Take this example where you want your dump script to honor ignored tables.

```ruby
require 'dumpdb'

class MysqlLimitedRestore
  include Dumpdb::Script

  # ...
  dump { "mysqldump -u :user -p :pw :db #{ignored_tables} | bzip2 > :fetch" }
  # ...

  def initialize(opts={})
    opts[:ignored_tables] ||= []
    @opts = opts
  end

  def ignored_tables
    opts[:ignored_tables].collect do |table|
      "--ignore-table=#{source.db}.#{table}"
    end.join(' ')
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
