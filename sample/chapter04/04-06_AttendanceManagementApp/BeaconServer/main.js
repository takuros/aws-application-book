var Bleacon = require("bleacon");

var uuid = "0123456789abcdef0123456789abcdef";  // UUID
var major = 10;  // Major
var minor = 20;  // Minor
var measuredPower = -59;  // 

Bleacon.startAdvertising(uuid, major, minor, measuredPower);
