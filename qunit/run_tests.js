load("./lib/math.js");
load("./lib/incr.js");

load("../../vendor/qunit/qunit/qunit.js");
load("../../lib/qunit-tap.js");

qunitTap(QUnit, print, {noPlan: true});

QUnit.init();
QUnit.config.updateRate = 0;

load("./test/math_test.js");
load("./test/incr_test.js");
load("./test/tap_compliance_test.js");

QUnit.start();
