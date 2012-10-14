as\_watage\_plugin
===================

This plugin enables you to upload file to watage.

Setup
----------------

Add folowing line to `filter.yml` to enable this plugin

    - name: as_watage_plugin

And `setting.yml`

    attachment_policy: watage
    attachment_path: https://your-watage.heroku.com/
