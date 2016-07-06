var test = require('tape');

var mss = require('../index');

test('mixin names', function (t) {
  var data = mss.parse('box {} \n sphere {}');
  t.ok('box' in data.mixins);
  t.ok('sphere' in data.mixins);
  t.end();
});

test('single-prop boolean component', function (t) {
  var data = mss.parse('visible { visible: true; }');
  t.equal(data.mixins.visible.visible, 'true');
  t.end();
});

test('single-prop vec3 component', function (t) {
  var data = mss.parse('upLeft { position: -1 1 0; }');
  t.equal(data.mixins.upLeft.position, '-1 1 0');
  t.end();
});

test('multi-prop component with one defined prop', function (t) {
  var data = mss.parse('red { material { color: red; } }');
  var material = data.mixins.red.material;
  t.equal(material.color, 'red');
  t.end();
});

test('multi-prop component with multiple defined props', function (t) {
  var data = mss.parse('box { geometry { primitive: box; width: 5; } }');
  var geometry = data.mixins.box.geometry;
  t.equal(geometry.primitive, 'box');
  t.equal(geometry.width, '5');
  t.end();
});
