module("TAP spec compliance");

test('Diagnostic lines' , function() {
         ok(true, "with\r\nmultiline\nmessage");
         equals("foo\nbar", "foo\r\nbar", "with\r\nmultiline\nmessage");
         equals("foo\r\nbar", "foo\nbar", "with\r\nmultiline\nmessage");
     });
