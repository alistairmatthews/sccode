(
var path = "C:/Users/AlistairM/Documents/MakingMusic/samples/MySamples/";

path;

~bfeedback = Buffer.read(s, path ++ "MagicHour.wav");
)

~bfeedback.query;
~bfeedback.plot;
~bfeedback.play;
Buffer.freeAll;

(
SynthDef.new(\magicHour, {
	arg amp = 1, out = 0, rate = 1, attack = 0.1, release = 5, buf;
	var sig, env;
	// The BufRateScale UGen handles what happens when the buffer's sample rate
	// doesn't match the server's sample rate.
	sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, doneAction:2);
	env = EnvGen.kr(Env.perc(attack, release), doneAction: Done.freeSelf);
	sig = sig * env;
	sig = sig * amp * 0.5; //the 0.3 is to handle polyphony without clipping
	Out.ar(out, sig.dup);
}).add;
)

(
//play a dominant 7 chord
Synth.new(\magicHour, [\buf, ~bfeedback.bufnum, \release, 10]);
Synth.new(\magicHour, [\buf, ~bfeedback.bufnum, \rate, -2.midiratio]);
Synth.new(\magicHour, [\buf, ~bfeedback.bufnum, \rate, -12.midiratio]);
Synth.new(\magicHour, [\buf, ~bfeedback.bufnum, \rate, 7.midiratio]);
Synth.new(\magicHour, [\buf, ~bfeedback.bufnum, \rate, 4.midiratio]);
)

(
p = Pbind(
	\instrument, \magicHour,
	\rate, Prand([1, -24, -12, 7, 4], inf).midiratio,
	\attack, Pwhite(0.5, 2),
	\release, Pwhite(0.5, 5)
).play;
)

TempoClock.default.tempo = 10;

p.stop;

s.freeAll;
s.scope;
s.plotTree;