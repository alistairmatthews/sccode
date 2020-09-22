//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//display the meter
s.meter;

//TODO:
//1. Experiment with guitar sounds. Done
//2. Build a UI
//3. Add MIDI pedal support
//4. Move reusable bits into classes or quarks. Done

//UI:
//a button/footswitch for in/out. This could either divert the in signal, or actually stop the granulator
//a b/f for randomized grains
//a radio button/3 footswitches for octave

(

//Set up the buffer to which sound is recorded
//It's 5 seconds and one channel
b = Buffer.alloc(s, s.sampleRate * 5, 1);

~ajmGranulator = AjmGranulator.new;

//Set up the four SynthDefs
~ajmGranulator.makeSynthDefs;

//Set up the two audio buffers, four groups to order Synths correctly,
//plus the three utility synths (all except the granulator)
~ajmGranulator.makeSynths(s, b);

//Create 20 granulators
~g = 20.collect({
	arg n;
	Synth(\granulator, [
		//This line means grains further from the recptr are quieter
		//so events seem to fade out
		\amp, n.linlin(0, 19, -3, -20).dbamp,
		\buf, b,
		\out, 0,
		\atk, 1,
		\rel, 1,
		\gate, 1,
		\sync, 0,
		\dens, exprand(20, 40),
		\baseDur, 0.08,
		\durRand, 1.5,
		\rate, 1,
		\rateRand, 0.5.midiratio,
		\pan, 0,
		\panRand, 0.5,
		\grainEnv, -1,
		\ptrBus, ~ptrBus,
		//This line spreads the five synths evenly to five different
		//playback points
		\ptrSampleDelay, n.linlin(0, 19, 1000, s.sampleRate * 2),
		\ptrRandSamples, 10000,
		\minPtrDelay, 1000,
	], ~grainGrp);
});
)

~g.do({ arg n; n.set(\rateRand, 0.0.midiratio)});
~g.do({ arg n; n.set(\rateRand, 100.0.midiratio)});

~g.do({ arg n; n.set(\rate, 0.5)});
~g.do({ arg n; n.set(\rate, 1)});
~g.do({ arg n; n.set(\rate, 2)});
~g.do({ arg n; n.set(\rate, 4)});

~g.do({ arg n; n.set(\sync, 0)});
~g.do({ arg n; n.set(\sync, 1)});


//Stop the granulator by closing the gate
~g.do({ arg n; n.set(\gate, 0)});

//Testing the content of the buffer
b.plot;
s.defaultGroup.deepFree;
b.play;