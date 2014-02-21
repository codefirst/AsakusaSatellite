AsakusaSatellite
===================

[![Build Status](https://secure.travis-ci.org/codefirst/AsakusaSatellite.png?branch=master)](http://travis-ci.org/codefirst/AsakusaSatellite) [![Code Climate](https://codeclimate.com/github/codefirst/AsakusaSatellite.png)](https://codeclimate.com/github/codefirst/AsakusaSatellite) [![Coverage Status](https://coveralls.io/repos/codefirst/AsakusaSatellite/badge.png?branch=master)](https://coveralls.io/r/codefirst/AsakusaSatellite) [![wercker status](https://app.wercker.com/status/b901326474567a915d89a93aed4b1ad5/s/ "wercker status")](https://app.wercker.com/project/bykey/b901326474567a915d89a93aed4b1ad5)

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

 * Ruby 1.8.7 / 1.9.3 / 2.0.0 / 2.1.0 or JRuby 1.7.1
 * RubyGems 1.4.2 or later
 * Bundler 1.0.7 or later
 * MongoDB 1.8.1 or later

Install
----------------

Install dependencies:

    $ bundle install --path .bundle --without development test

Precompile assets:

    $ bundle exec rake assets:precompile RAILS_ENV=production

If you upgrade AS from 0.7.0 or older, execute following:

    $ curl https://raw.github.com/gist/2792357/asakusasatellite_migration_for_v0.7.0 | mongo <db_name>

Excecute mongodb and socky:

    $ mongod --dbpath <dir_name>
    $ bundle exec thin -R socky/config.ru -p3002 -t0 start

Run AsakusaSatellite:

    $ bundle exec rails s -e production

and access to http://localhost:3000/

For JRuby user
---------------

### How to deploy

    $ bundle exec rake assets:precompile
    $ bundle exec warble

### limitation

 * Don't use socky on JRuby. use keima or pusher
 * Don't use newrelic

For developers
---------------

### Install for Developer

    $ cp misc/bleis-hooks/* .git/hooks

### Test

You need test db to run tests.

    $ mongod --dbpath <test_dir_name>

#### individual testing

    $ bundle exec rspec spec/{controller,model}/$(name)_spec.rb

#### test all

    $ bundle exec rake

#### run with rcov

    $ bundle exec rake spec:rcov

#### auto testing

    $ bundle exec guard start

#### JavaScript testing

Requirement: phantomjs 1.5+

    $ bundle exec rake qunit

### Generate Plugin Template

#### generate filter

    $ rails g as_filter test

edit filies

 * plugins/as_test_filter/lib/test_filter.rb
 * plugins/as_test_filter/spec/lib/test_filter_spec.rb

edit config/filters.yml

    - name: test_filter

#### generate viewhook

    $ rails g as_viewhook test

edit files

 * plugins/as_test/lib/test.rb
 * plugins/as_test/spec/lib/test_spec.rb

Thanks
----------------

### Very cute icons

Several icons is created by Mark James and distributed at [mini icons - famfamfam.com](http://www.famfamfam.com/lab/icons/mini/).

### Cool sound

Cool sound is created by [On-Jin](http://yen-soft.com/ssse/). Do not redestribute the sound file.

### Redmine logo

Redmine Logo is Copyright (C) 2009 Martin Herr and is licensed under ThereCreative Commons Attribution-Share Alike 2.5 Generic license.

See http://creativecommons.org/licenses/by-sa/2.5/ for more details.
