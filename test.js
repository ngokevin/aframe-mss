var fs = require('fs');
var parser = require('./parser/main');

var contents = fs.readFileSync('parser/test-aframe.mss', 'utf-8');
var parsed = parser.parse(contents);
console.log(JSON.stringify(parsed));
