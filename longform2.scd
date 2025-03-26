(
m = MIDIIn.connectAll;
MIDIdef()
)

(
SynthDef(\bpfsaw, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cf=1500, rq=0.2, amp=1, out=0|
	var sig, env;
	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env * amp;
	Out.ar(out, sig!2);
}).add;
)

Synth(\bpfsaw);

(
[58, 65, 68, 73].midicps.do{
	|f|
	Synth(
		\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
			\cf, f * exprand(1, 12),
			\rq, exprand(0.01, 0.5)
		]
	)
}
)


(
14.do{
	Synth(
		\bpfsaw,
		[
			\freq, exprand(44, 12000).round(44),
			\amp, 0.25,
			\cf, exprand(200, 500),
			\rq, exprand(0.01, 0.5)
		]
	)
}
)

(
14.do{
	Synth(
		\bpfsaw,
		[
			\freq, (Scale.partch_o1.degrees+66).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200, 500),
			\rq, exprand(0.01, 0.5)
		]
	)
}
)

Scale.directory
(
(1..60).choose.do{
	Synth(
		\bpfsaw,
		[
			\freq, (Scale.partch_u6.degrees+44).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200, 5000).round(44),
			\rq, exprand(0.01, 1.05)
		]
	)
}
)



(
SynthDef(\bpfsaw0, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cfmin=500, cfhzmin=0.1, cfhzmax=0.3, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, lsf=200, ldb=0 out=0, detune=0.2, pan = 0|
	var sig, env;
	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);
	/*sig = PanAz.ar(8, sig, LFNoise1.kr(0.5));*/
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)



(
10.do{Synth(\bpfsaw0, [\amp, 0.25, \freq, (Scale.partch_o1.degrees + 30).midicps.choose, \detune, exprand(0.07, 0.9)])};
10.do{Synth(\bpfsaw0, [\amp, 0.2, \freq, (Scale.partch_o1.degrees + 30).midicps.choose,\detune, rrand(0.50, 0.75), \atk, 0.01, \sus, 10.0, \rel, 10])};
)

x.set(\freq, 1000);



(
x = (1..127).do{
	Synth(
		\bpfsaw0,
		[
			\freq, exprand(44,440.5).round(42),
			\amp, 0.5,
			\cfmin, 44 * 2,
			\cfmax, 43.5 * 420,
			\rqmin, exprand(0.006, 0.08),
			\rqmax, exprand(0.03, 0.1),
			\cfhzmin, rrand(0.1,7),
			\cfhzmax, rrand(0.01, 7),
			\atk, 10,
			\sus, 20,
			\rel, 10,
			\pan, rrand(-1.0, 1.0)
		]
	);
};
)
x.stop;


(
(1..127).choose.do{
	x = Synth(
		\bpfsaw0,
		[
			\freq, (Scale.partch_u6.degrees+44).midicps.choose,
			\amp, exprand(0.75, 1.0),
			\cfmin, exprand(40.0, 500.0),
			\cfmax, exprand(50.0, 400.0),
			\rqmin, exprand(0.01, 0.05),
			\rqmax, exprand(0.05, 0.8).midicps.reciprocal,
			\pan, rrand(-1.0, 1.0)
		]
	)
}
)
x.set(\freq, 1000);



//nested noise
x  = {SinOsc.ar(LFNoise0.kr(LFNoise0.kr(8).exprange(42, 420)).exprange(0.5, 0.7, 0.125))!2}.play;
x.play;
x.free;



//patterns
(
Pdef(
	\bpsawpat,
	Pbind(
		\instrument, \bpfsaw0,
		\dur, Pexprand(0.05, 1.0, inf).trace,
		\midinote, Pseq([44, 88, 45, 87], inf),
		\detune, Pseq([0.08,0.8, 2, 0.05], inf),
		\cfmin, Pexprand(100, (100*2)/2),
		\cfmax, Pexprand(150,1500),
		\atk, Pwhite(0.001, 4.0).trace,
		\rel, Pwhite(8.0, 10.0),
		\ldb, rrand(0, 6),
		\amp, 0.75.reciprocal,
		\pan, Pwhite(-1.0, 1.0, inf),
	)
).play;
)


s.plotTree;


//queasy
(
Pdef(
	\bpfsawpat1,
	Pbind(
		\instrument, \bpfsaw0,
		\dur, Pwhite(0.05, 10.0, inf),
		\midinote, Pseq([
			[43, 45, 70],
			[46, 60.5, 57.5],
			[50, 62.5, 59].
			[48, 63, 75.5]
		], inf),
		\detune, Pexprand(0.08, 11.9),
		\cfmin, Pexprand(10, 200, inf),
		\cfmax, Pexprand(150, 2000, inf),
		\atk, Pgbrown(0.01, 10.0, 0.125, inf),
		\sus, Pwhite(2.0, 8.0, inf),
		\rel, Pwhite(0.02, 10.0, inf),
		\c1, Pexprand(0.1, 10.0, inf),
		\freq, Pexprand(44, 88, inf),
		\cfhzmin, Pexprand(88.0, 880.0, inf),
		\cfhzmax, Pcauchy(0.0, exprand(0.125,0.25), inf),
		\rqmin, Pexprand(0.05, 0.08, inf),
		\rqmax, Pgbrown(0.01, 2.0, 0.0125, inf),
		\ldb, rrand(0, 6),
		\amp, 0.5,
		\pan, Pwhite(-1.0, 1.0, inf),
		\out, 0
	)
).play;
)

//|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cfmin=500, cfhzmin=0.1, cfhzmax=0.3, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, lsf=200, ldb=0 out=0, detune=0.2, pan = 0|



s.scope;
FreqScope()







