load("./lib/math.js");
load("./lib/incr.js");

load("../../vendor/qunit/qunit/qunit.js");
load("../../lib/qunit-tap.js");

QUnit.init();
QUnit.config.blocking = false;
QUnit.config.autorun = true;
QUnit.config.updateRate = 0;
QUnit.tap.showDetailsOnFailure = true;

print("1..16");
load("./test/math_test.js");
//load("./test/incr_test.js");
//load("./test/tap_compliance_test.js");
