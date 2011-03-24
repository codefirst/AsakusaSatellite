module("incr module");

test('increment' , function() {
         var inc = incr.increment;
         equals(inc(1), 2);
         equals(inc(-3), -2);
     });
