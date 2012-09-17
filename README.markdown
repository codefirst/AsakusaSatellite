AsakusaSatellite
===================

[![Build Status](https://secure.travis-ci.org/codefirst/AsakusaSatellite.png?branch=master)](http://travis-ci.org/codefirst/AsakusaSatellite)

Overview
----------------
AsakusaSatellite is a realtime chat application for Developers.

Authors
----------------
 * @suer
 * @mallowlabs
 * @mzp
 * @shimomura1004
 * @banjun

Requirement
----------------
 * Ruby 1.8.7
 * RubyGems 1.4.2 or later
 * Bundler 1.0.7 or later
 * MongoDB 1.8.1 or later

Install
----------------

Install dependencies:

    $ bundle install --path vendor/bundle

If you upgrade AS from 0.7.0 or older, execute following:

    $ curl https://raw.github.com/gist/2792357/asakusasatellite_migration_for_v0.7.0 | mongo <db_name>

Excecute mongodb and socky:

    $ mongod --dbpath <dir_name>
    $ bundle exec thin -R socky/config.ru -p3002 -t0 start

Run AsakusaSatellite:

    $ bundle exec rails server

and access to http://localhost:3000/

### Install for Developer

    $ cp misc/bleis-hooks/* .git/hooks


### Test

You need test db to run tests.

    $ mongod --dbpath <test_dir_name>

#### indivisual testing

    $ bundle exec ruby spec/{controller,model}/$(name)_spec.rb

#### test all

    $ bundle exec rake spec

#### run with rcov

    $ bundle exec rake spec:rcov

#### auto testing

    $ bundle exec guard start

#### JavaScript testing

Requirement: phantomjs 1.5+

    $ cd qunit
    $ ./phantomjs_test.sh

### Generate Filter Plugin

#### generate

    $ rails g as_filter test

edit filies

 * plugins/as_test_filter/lib/test_filter.rb
 * plugins/as_test_filter/spec/lib/test_filter_spec.rb

edit config/filters.yml

    - name: test_filter

Thanks
----------------

### Very cute icons

Several icons is created by Mark James and distributed at [mini icons - famfamfam.com](http://www.famfamfam.com/lab/icons/mini/).

### Cool sound

Cool sound is created by [On-Jin](http://yen-soft.com/ssse/). Do not redestribute the sound file.

### Redmine logo

Redmine Logo is Copyright (C) 2009 Martin Herr and is licensed under ThereCreative Commons Attribution-Share Alike 2.5 Generic license.

See http://creativecommons.org/licenses/by-sa/2.5/ for more details.
