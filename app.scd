/*s.reboot;
(
MIDIClient.init;
m = MIDIIn.connectAll;
~bend = 8192;
~notes = Array.newClear(128);
)

(
MIDIdef.noteOn(\noteOnTest, {
	|vel, nn, chan, src|
	[vel, nn, chan, src].postln;
	~notes[nn] = Synth(\bpfsaw,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1, 127, 0.01, 0.3),
			\gate, 1,
			\bend, ~bend.linlin(0, 16383, -2, 2)
		]
	);
});

MIDIdef.noteOff(\noteOffTest, {
	|vel, nn|
	[vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});

MIDIdef.bend(\bendTest, {
	|val, chan, src|
	[val, chan, src].postln;
	~bend = val;
	~notes.do{
		|synth|
		synth.set(\bend, val.linlin(0, 16383, -2, 2))
	};
}, chan: 0);

)*/


/*(
SynthDef(\tone, {
	|freq=440, amp=0.3, gate=0, bend=0|
	var sig, env;
	sig = LFTri.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.adsr, gate,  doneAction: 2);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

Synth(\tone, [\freq, 700, \amp, 0.5]);*/

s.boot;
s.meter;
s.plotTree;
(
SynthDef(\bpfsaw, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cf=1500, rq=0.2, amp=1, out=0|
	var sig, env;
	env = EnvGen.kr([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2], doneAction: 2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)
Synth(\bpfsaw);

(
4.do{
	Synth(
		\bpfsaw,
		[
			\freq, exprand(100, 1000),
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5)
		]
	);
};
)

