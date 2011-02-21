AsakusaSatellite
===================

AsakusaSatellite is a realtime chat application for Developers.

Authors
----------------
 * @suer
 * @mallowlabs
 * @mzp

Requirement
----------------
 * Ruby 1.8.7
 * Rails 3.0.3 or later

Install
----------------

    $ bundle install --path vendor/bundle
    $ rake groonga:migrate
    $ cp config/filter.yml.example config/filter.yml
    $ cp config/websocket.yml.example config/websocket.yml
    $ cp config/settings.yml.example config/settings.yml

### Install for Developer

    $ cp bleis-hooks/* .git/hooks

### Access

    $ rails server
    $ ruby websocket/server

access to http://localhost:3000/

### Test
#### setup

    $ rake groonga:migrate RAILS_ENV=test

#### indivisual testing

    $ ruby spec/{controller,model}/$(name)_spec.rb

#### test all

    $ rake spec

#### run with rcov

    $ rake spec:rcov

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

