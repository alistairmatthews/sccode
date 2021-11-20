
// Path to demonstrate the additive poly synth

//Boot the synth and create the synth
s.waitForBoot({	~sjmAdditivePolySynth = AjmAdditivePolySynth.new(); });

//Demo single notes
y = Synth.new(\addPolySynth, ["freq", 200, "out", 0]);
y = Synth.new(\addPolySynth, ["freq", 250, "out", 0, "attack", 1, "release", 10]);
y.free;

//Demo using a pattern
(
p = Pbind(
	\instrument, \addPolySynth,
	\midinote, 50, //Using \midinote and \harmonic to set the \freq arg
	\harmonic, Pexprand(1, 10).round.trace, //.trace sends the harmonic to the PostBuffer
	\dur, Pwhite(0.2, 1),
	\vol, 0.5,
	\attack, Pwhite(0.5, 2),
	\release, Pwhite(0.5, 5),
).play;
)

//Change the speed of the clock
TempoClock.default.tempo = 2;
TempoClock.default.tempo = 1;

//Stop playing
p.stop;

//Show the tree and the oscilloscope
s.plotTree;
s.scope;
