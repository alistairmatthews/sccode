
// A simple synthdef with harmonics of trig waves
(

s.waitForBoot({
	
	SynthDef.new(\multiNote, {
		arg freq = 440, attack = 0.1, release = 1, vol = 1, out;
		var sig, env;
		//sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.5) + (SinOsc.ar(freq * 4) * 0.25);
		sig = LFTri.ar(freq) + (LFTri.ar(freq * 2) * 0.5) + (LFTri.ar(freq * 4) * 0.25);
		sig = sig * 0.3;
		env = EnvGen.kr(Env.perc(attack, release), doneAction: Done.freeSelf);
		sig = sig * env * vol;
		Out.ar(out, sig.dup);
	}).add;
});
)

Env.perc(1, 10).plot;

y = Synth.new(\multiNote, ["freq", 200, "out", 0]);
y = Synth.new(\multiNote, ["freq", 250, "out", 0, "attack", 1, "release", 10]);
y.free;

(
p = Pbind(
	\instrument, \multiNote,
	\midinote, 50, //Using \midinote and \harmonic to set the \freq arg
	\harmonic, Pexprand(1, 10).round.trace,
	\dur, Pwhite(0.2, 1),
	\vol, 0.5,
	\attack, Pwhite(0.5, 2),
	\release, Pwhite(0.5, 5),
).play;
)

TempoClock.default.tempo = 1;

p.stop;

s.plotTree;
s.scope;
