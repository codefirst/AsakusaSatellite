AsakusaSatellite
===================
uethutohueonu
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
AsakusaSatellite needs mongod.

    $ mongod --dbpath <dir_name>

Settings

    $ cp config/filter.yml.example config/filter.yml
    $ cp config/websocket.yml.example config/websocket.yml
    $ cp config/settings.yml.example config/settings.yml
    $ cp config/mongoid.yml.example config/mongoid.yml
    $ bundle install --path vendor/bundle

### Install for Developer

    $ cp bleis-hooks/* .git/hooks

### Access

    $ bundle exec rails server

access to http://localhost:3000/

### Test
#### indivisual testing

    $ bundle exec ruby spec/{controller,model}/$(name)_spec.rb

#### test all

    $ bundle exec rake spec

#### run with rcov

    $ bundle exec rake spec:rcov

#### autotest

create .autotest file

    require 'autotest/timestamp'
    require 'autotest/growl'

run autotest task

    $ bundle exec autotest

### Generate Filter Plugin

#### generate

    $ rails g as_filter test

edit filies

 * vendor/plugins/as_test_filter/lib/test_filter.rb
 * vendor/plugins/as_test_filter/spec/lib/test_filter_spec.rb

edit config/filters.yml

    - name: test_filter

### Thanks

 * Very cute icons: [mini icons - famfamfam.com](http://www.famfamfam.com/lab/icons/mini/)

 * Cool sound: [On-Jin](http://yen-soft.com/ssse/)

Do not redestribute the sound file.
