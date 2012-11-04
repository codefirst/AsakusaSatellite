as\_redmineauth\_plugin
===================

A authentication plugin using Redmine REST API access key.

Setup
----------------

1. Edit <AS_ROOT>/config/settings.yml

        omniauth:
          provider: 'redmine'
          provider_args:
            - 'http://redmine.host/path'

2. Restart AsakusaSatellite

3. Click 'Login' link and input your API access key.
