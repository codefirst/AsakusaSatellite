desc "Run all QUnit tests"
task "qunit" do
  require 'yaml'

  class QUnit
    def initialize(path)
      @setting    = YAML.load_file(path)
      @html_file  = "#{Rails.root}/tmp/#{@setting['name']}_index.html"
      @url        = "file://#{@html_file}"
      @tap_file   = "#{Rails.root}/tmp/#{@setting['name']}.tap"
      @qunit_root = "#{Rails.root}/qunit"
    end

    def generate_html
      File::open(@html_file, "w") do |f|
        f.write <<EOF
<!DOCTYPE html>
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
  <link rel="stylesheet" href="#{@qunit_root}/lib/qunit/qunit.css" type="text/css" media="screen">
  <script type="text/javascript" src="#{@qunit_root}/lib/qunit/qunit.js"></script>
  <script type="text/javascript" src="#{@qunit_root}/lib/qunit-tap.js"></script>
  <script>
    qunitTap(QUnit, function() { console.log.apply(console, arguments); }, {noPlan: true});
  </script>
#{@setting['files'].map{|f| "<script type='text/javascript' src='file://#{Rails.root}/#{f}'></script>"}.join"\n"}
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

    def execute_test
      File::open(@tap_file, "w") do |f|
        output = %x(phantomjs #{@qunit_root}/run_qunit.js #{@url})
        f.write(output)
        puts(output)
      end
      return $?.exitstatus == 0
    end

    def run
      generate_html
      execute_test
    end
  end

  settings = ["#{Rails.root}/qunit/qunit_setting.yml"] + Dir::glob("#{Rails.root}/plugins/*/qunit/qunit_setting.yml")
  results = settings.map {|setting| QUnit.new(setting).run}
  exit(results.all?)
end
