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

# TODO: basic example

### Configure

Dumpdb needs to be told about your source and target databases.  Specifically, it needs to know the host, user, pw, and database name for each.

# TODO: examples

### Define your script

Dumpdb assumes your scripts have 3 types of commands: dump, fetch, and restore.  Dump commands are run on the source host and dump the database into a single file.  Restore commands are run locally and take the dump file and rebuild the database from it.  The fetch command specifies the name of the dump file to copy from the source host.

# TODO: example

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
