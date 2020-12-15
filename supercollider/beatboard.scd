s.boot;
s.doWhenBooted({
  /*~~~~~~~~~~SynthDefs~~~~~~~~~~*/
  //These should definitely be saved to files...

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

  SynthDef(\snare, {arg out = 0, amp = 0.3, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
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

  SynthDef(\kick_808, {arg out = 0, freq1 = 240, freq2 = 60, amp = 1, ringTime = 10, rel = 1, dist = 0.5, pan = 0;
    var snd, env;
	  snd = Ringz.ar(
		  in: Impulse.ar(0), // single impulse
		  freq: XLine.ar(freq1, freq2, 0.1),
		  decaytime: ringTime);
	  env = EnvGen.ar(Env.perc(0.001, rel, amp), doneAction: 2);
	  snd = (1.0 - dist) * snd + (dist * (snd.distort));
	  snd = snd * env;
	  Out.ar(0, Pan2.ar(snd, pan));
    //
    //By Bruno Ruviaro
    //https://github.com/brunoruviaro/SynthDefs-for-Patterns/blob/master/kick808.scd
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
  SynthDef(\bass, { |out=0, freq = 220, amp = 1|
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

    //Final attenuation
    sig = MulAdd(sig, amp);

    Out.ar(out, sig);
  }).add;

  /* ~~~~~~~~~~ Patterns! ~~~~~~~~~~~~~~ */

  //----hihat----//
  Pdefn(\hihatAmp, 0.5);
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
    \dur, Pn(~hhRandMeasure, inf),
    \amp, Pdefn(\hihatAmp)
  );

  ~hh16Pattern = Pbind(
    \instrument, \hihat,
    \dur, Pn(Pseq([0.25], 16), inf),
    \amp, Pdefn(\hihatAmp)
  );

  //----kick----//
  Pdefn(\kickAmp, 1);
  ~kick1Measure = [1, 1, 1, 1];
  ~kick2Measure = [0.75, 0.25, Rest(0.5), 0.5, Rest(0.5), 0.5, Rest(0.5), 0.5];

  ~kick1Pattern = Pbind(
    \instrument, \kick_808,
    \dur, Pseq(~kick1Measure, inf),
    \amp, Pdefn(\kickAmp)
  );

  ~kick2Pattern = Pbind(
    \instrument, \kick_808,
    \dur, Pseq(~kick2Measure, inf),
    \amp, Pdefn(\kickAmp)
  );

  //----Snare----//
  Pdefn(\snareAmp, 0.7);

  ~snMeasure = [Rest(1), 1, Rest(1), 1];

  ~sn1Pattern = Pbind(
    \instrument, \snare,
    \dur, Pseq(~snMeasure, inf),
    \amp, Pdefn(\snareAmp)
  );

  ~sn2Pattern = Pbind(
    \instrument, \neurosnare,
    \dur, Pseq(~snMeasure, inf),
    \amp, Pdefn(\snareAmp)
  );

  //--Bass--//
  PatternProxy.defaultQuant = 1; //Use more pattern proxies!!
  Pdefn(\bassRoot, 0);
  Pdefn(\bassAmp, 0.9);
  ~bassNotes = PatternProxy(Pseq([Pdefn(\bassRoot), Pdefn(\bassRoot)], 4));
  ~bassOctaves = PatternProxy(Pseq([3, 4], 4));
  ~bassDurs = PatternProxy(Pseq([0.5, 0.5], 4));
  ~bassPattern = Pn(Pbind(
    \instrument, \bass,
    \scale, Scale.major,
    \degree, ~bassNotes,
    \octave, ~bassOctaves,
    \dur, ~bassDurs,
    \amp, Pdefn(\bassAmp)
  ), inf);

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
        ~kickStream = ~kick1Pattern.play(quant: 4);
      },
      2, {
        "setting kick to pattern 2".postln;
        ~kickStream.stop;
        ~kickStream = ~kick2Pattern.play(quant: 4);
      },
      '/amp', {
        ("setting kick amp to" + msg[2]).postln;
        Pdefn(\kickAmp, msg[2]);
      }
    );
  }, '/kick');

  OSCdef(\snare, {|msg, time, addr, recvPort|
    switch(msg[1],
      1, {
        ~snStream.stop;
        ~snStream = ~sn1Pattern.play(quant: 4);
      },
      2, {
        ~snStream.stop;
        ~snStream = ~sn2Pattern.play(quant: 4);
      },
      '/amp', {
        ("setting snare amp to" + msg[2]).postln;
        Pdefn(\snareAmp, msg[2]);
      }
    );
  }, '/snare');

  OSCdef(\hihat, {|msg, time, addr, recvPort|
    switch(msg[1],
      1, {
        ~hhStream.stop;
        ~hhStream = ~hhRandPattern.play(quant: 4);
      },
      2, {
        ~hhStream.stop;
        ~hhStream = ~hh16Pattern.play(quant: 4);
      },
      '/amp', {
        ("setting hihat amp to" + msg[2]).postln;
        Pdefn(\hihatAmp, msg[2]);
      }
    );
  }, '/hihat');

  OSCdef(\drums, {|msg, time, addr, recvPort|
    msg[1].postln;
    switch(msg[1],
      '/start', {
        "start drums".postln;
        ~hhStream = ~hh16Pattern.play(quant:4);
        ~snStream = ~sn1Pattern.play(quant:4);
        ~kickStream = ~kick1Pattern.play(quant:4);
      },
      '/stop', {
        "stop drums".postln;
        ~hhStream.stop;
        ~snStream.stop;
        ~kickStream.stop;
      }
    )
  }, '/drums');

  OSCdef(\bass, {|msg, time, addr, recvPort| //addr, numargs, args
    msg.postln;
    switch(msg[1],
      '/root', { //using ugly hard code here for now until I can jank together a way to send an array over OSC
        Pdefn(\bassRoot, msg[2]);
      },
      '/pattern', {
        switch(msg[2],
          1, {
            ~bassDurs.source = Pseq([0.5, 0.5], 4); //The pattern to set to
            ~bassNotes.source = Pseq([Pdefn(\bassRoot), Pdefn(\bassRoot)], 4); //set a default that will work with this rhythm
            ~bassOctaves.source = Pseq([3, 4], 4);
          },
          2, {
            ~bassDurs.source = Pseq([1/3, 1/3, 1/3], 4); //The pattern to set to
            ~bassNotes.source = Pseq([Pdefn(\bassRoot), (Pdefn(\bassRoot) + 4) % 7, Pdefn(\bassRoot)], 4); //set a default that will work with this rhythm
            ~bassOctaves.source = Pseq([3, 3, 4], 4); //same ^
          }
        );
      },
      '/amp', {
        ("setting bass amp to" + msg[2]).postln;
        Pdefn(\bassAmp, msg[2]);
      },
      '/start', {
        ~bassStream = ~bassPattern.play(quant:4);
      },
      '/stop', {
        ~bassStream.stop;
      }
    );
  }, '/bass');

  /*
  OSCdef(\pad, {|msg, time, addr, recvPort|
  }, '/pad');
  */
});

