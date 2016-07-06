var fs = require('fs');
var test = require('tape');

var mss = require('../parser/main');

var contents = fs.readFileSync('tests/files/integration.mss', 'utf-8');

test('parses', function (t) {
  var data = mss.parse(contents);
  t.ok(data);
  t.end();
});
