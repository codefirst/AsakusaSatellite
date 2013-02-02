#!/usr/bin/env ruby
require 'yaml'

def generate_index_html(prefix, files)
  File::open("#{prefix}_index.html", "w") do |f|
    f.write <<EOF
# <!DOCTYPE html>
<html>
<head>
  <meta content="text/html; charset=UTF-8" http-equiv="content-type">
  <title>QUnit Test Suite</title>
  <script>
    var AsakusaSatellite = {
      current : {
        user : "user",
        room : "000000000000000000000000"
      }
    };
  </script>
  <link rel="stylesheet" href="./lib/qunit/qunit.css" type="text/css" media="screen">
  <script type="text/javascript" src="./lib/qunit/qunit.js"></script>
  <script type="text/javascript" src="./lib/qunit-tap.js"></script>
  <script>
    qunitTap(QUnit, function() { console.log.apply(console, arguments); }, {noPlan: true});
  </script>
#{files.map{|f| "<script type='text/javascript' src='#{f}'></script>"}.join"\n"}
</head>
<body>
  <h1 id="qunit-header">QUnit Test Suite</h1>
  <h2 id="qunit-banner"></h2>
  <div id="qunit-testrunner-toolbar"></div>
  <h2 id="qunit-userAgent"></h2>
  <ol id="qunit-tests"></ol>
</body>
</html>
EOF
  end
end

def execute_test(name)
  File::open("#{name}.tap", "w") do |f|
    output = %x(phantomjs run_qunit.js file://#{Dir::pwd}/#{name}_index.html)
    f.write output
    puts output
  end
  $?.exitstatus == 0
end

(Dir::glob("*.html")+Dir::glob("*.tap")).each{|f| File.unlink f}

result = (["qunit_setting.yml"]+Dir::glob("../plugins/*/qunit/qunit_setting.yml")).map do |yaml|
  setting = YAML.load_file yaml
  name    = setting['name']
  files   = setting['files']

  if ARGV.empty? or ARGV.member? name
    path = File.dirname yaml
    generate_index_html(name, files.map{|f| File::expand_path(f, path)})
    execute_test(name)
  else
    false
  end
end.all?

exit result
