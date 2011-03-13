#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class AddYamlFieldToRooms < ActiveGroonga::Migration
 def up
   create_table(:rooms) do |table|
     table.short_text(:yaml)
   end
 end

 def down
   remove_column :rooms, :yaml
 end
end
