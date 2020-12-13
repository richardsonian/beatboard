s.boot;
s.doWhenBooted({
OSCdef(\test, {|msg, time, addr, recvPort|
  msg.postln;
}, '/test');
});