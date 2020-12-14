s.boot;
s.doWhenBooted({
  /*~~~~~~~~~~SynthDefs~~~~~~~~~~*/

  //From sccode.org: https://sccode.org/1-57f
  SynthDef(\neurosnare, {
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1));
    Out.ar(0, snd);
  }).add;

  //From sccode.org: https://sccode.org/1-54H
  SynthDef(\hihat, {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
    var env, snd;
    env = Env.perc(att, rel, amp).kr(doneAction: 2);
    snd = WhiteNoise.ar;
    snd = HPF.ar(in: snd, freq: ffreq, mul: env);
    Out.ar(out, Pan2.ar(snd, pan));
  }).add;

  SynthDef(\snare, {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
    var env, snd1, snd2, sum;
    env = Env.perc(att, rel, amp).kr(doneAction: 2);
    snd1 = HPF.ar(
      in: WhiteNoise.ar,
      freq: ffreq,
      mul: env
    );
    snd2 = SinOsc.ar(freq: sinfreq, mul: env);
    sum = snd1 + snd2;
    Out.ar(out, Pan2.ar(sum, pan));
  }).add;

  SynthDef(\kick, {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
    var env, snd, ramp;
    env = Env.perc(att, rel, amp).kr(doneAction: 2);
    ramp = XLine.kr(
      start: sinfreq,
      end: sinfreq * glissf,
      dur: rel
    );
    snd = SinOsc.ar(freq: ramp, mul: env);
    snd = Pan2.ar(snd, pan);
    Out.ar(out, snd);
  }).add;

  // Basic saw synth for chords and bass **UNUSED**
  SynthDef(\sawSynth, { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
      attackTime: att,
      releaseTime: rel,
      level: amp
    ).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
    snd = LPF.ar(
      in: snd,
      freq: LFNoise2.kr(1).range(lofreq, hifreq)
    );
    snd = Splay.ar(snd);
    Out.ar(0, snd);
  }).add;

  //Adapted from sccode.org: https://sccode.org/1-4YY
  SynthDef(\bass, { |out=0, freq = 220|
    var subfreq = freq / 2;

    // Envelopes
    var subenv = EnvGen.kr(Env.perc(0, 1), doneAction:2);
    var env = EnvGen.kr(Env.perc(0, 0.5));

    // Component synthesis
    var pluck = Pluck.ar(PinkNoise.ar, 1, 0.2, subfreq.reciprocal) * subenv * 2;
    var tri = VarSaw.ar(freq) * env;
    var sin = SinOsc.ar(freq) * env;
    var sub = (SinOsc.ar([subfreq, subfreq - 2, subfreq + 2]).sum * subenv).tanh;
    var click = RLPF.ar(Impulse.ar(0), [2000, 8000], 1).sum * 1000;

    // Initial signal
    var sig = pluck + tri + sub + click;

    // Resonant LPFs
    sig = RLPF.ar(sig, XLine.ar(freq * 100, freq * 10, 0.15));
    sig = sig + (MoogFF.ar(sig, freq * 20, 2.5) * 0.1);

    // EQ resulting signal
    sig = BPeakEQ.ar(sig, 400, 0.5, -9);
    sig = BPeakEQ.ar(sig, 2000, 0.5, 6);
    sig = BHiShelf.ar(sig, 8000, 1, 3);
    sig = BPeakEQ.ar(sig, 200, 1, 3);

    // Apply another envelope to dampen a bit more
    sig = sig * XLine.kr(1, 0.6, 0.1);

    // Tanh distortion / limiting
    sig = (sig * 1).tanh;

    // Another round of signal coloring, using another RLPF
    // and sine components
    sig = sig + RLPF.ar(sig, XLine.ar(freq * 100, freq * 10, 0.15)) + sin + sub;

    // Another round of tanh distortion / limiting
    sig = (sig / 2.3).tanh;

    // Another resonant LPF
    sig = MoogFF.ar(sig, XLine.ar(freq*150, freq*30, 0.1), 0.1);

    Out.ar(out, sig);
  }).add;

  /* ~~~~~~~~~~ Patterns! ~~~~~~~~~~~~~~ */

  //----hihat----//

  ~hhRandBeats = [
    Pseq([Rest(0.5), 0.25, 0.25]),
    Pseq([0.25, 0.25, Rest(0.5)]),
    Pseq([Rest(0.5), 0.5]),
    Pseq([0.75, 0.25]),
    Pseq([0.25, 0.75]),
    Pseq([0.5, 0.5])
  ];
  ~hhRandMeasure = Prand(~hhRandBeats, 4); //Combine 4 of these beats randomly into a measure

  ~hhRandPattern = Pbind(
    \instrument, \hihat,
    \amp, 0.1,
    \dur, Pn(~hhRandMeasure, inf)
  );

  ~hh16Pattern = Pbind(
    \instrument, \hihat,
    \dur, Pn(Pseq([0.25], 16), inf)
  );

  //----kick----//

  ~kick1Measure = [1, 1, 1, 1];
  ~kick2Measure = [0.75, 0.25, Rest(0.5), 0.5, Rest(0.5), 0.5, Rest(0.5), 0.5];

  ~kick1Pattern = Pbind(
    \instrument, \kick,
    \dur, Pseq(~kick1Measure, inf)
  );

  ~kick2Pattern = Pbind(
    \instrument, \kick,
    \dur, Pseq(~kick2Measure, inf)
  );

  //----Snare----//

  ~snMeasure = [Rest(1), 1, Rest(1), 1];

  ~sn1Pattern = Pbind(
    \instrument, \snare,
    \dur, Pseq(~snMeasure, inf),
  );

  ~sn2Pattern = Pbind(
    \instrument, \neurosnare,
    \dur, Pseq(~snMeasure, inf),
  );

 /*~~~~~~~~~~~~~~Control!~~~~~~~~~~~~~~~~~~~~~*/
  OSCdef(\tempo, {|msg, time, addr, recvPort|
    ("setting tempo to" + msg[1]).postln;
    TempoClock.default.tempo = (msg[1] / 60);
  }, '/tempo');

  OSCdef(\kick, {|msg, time, addr, recvPort|
    msg.postln;
    switch(msg[1],
      1, {
        "setting kick to pattern 1".postln;
        ~kickStream.stop;
        ~kickStream = ~kick1Pattern.play(quant: 4)
      },
      2, {
        "setting kick to pattern 2".postln;
        ~kickStream.stop;
        ~kickStream = ~kick2Pattern.play(quant: 4)
      }
    );
  }, '/kick');

  OSCdef(\snare, {|msg, time, addr, recvPort|
    switch(msg[1],
      1, {
        ~snStream.stop;
        ~snStream = ~sn1Pattern.play(quant: 4)
      },
      2, {
        ~snStream.stop;
        ~snStream = ~sn2Pattern.play(quant: 4)
      }
    );
  }, '/snare');

  OSCdef(\hihat, {|msg, time, addr, recvPort|
    switch(msg[1],
      1, {
        ~hhStream.stop;
        ~hhStream = ~hhRandPattern.play(quant: 4)
      },
      2, {
        ~hhStream.stop;
        ~hhStream = ~hh16Pattern.play(quant: 4)
      }
    );
  }, '/hihat');

  OSCdef(\bass, {|msg, time, addr, recvPort|

  }, '/bass');

  OSCdef(\pad, {|msg, time, addr, recvPort|

  }, '/pad');

  OSCdef(\drums, {|msg, time, addr, recvPort|
    msg[1].postln;
    switch(msg[1],
      '/start', {
        "start drums".postln;
        ~hhStream = ~hh16Pattern.play(quant:0);
        ~snStream = ~sn1Pattern.play(quant:0);
        ~kickStream = ~kick1Pattern.play(quant:0);
      },
      '/stop', {
        "stop drums".postln;
        ~hhStream.stop;
        ~snStream.stop;
        ~kickStream.stop;
      }
    )
  }, '/drums');
});

NetAddr.localAddr.sendMsg("/kick", 2)


