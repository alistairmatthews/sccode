//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//display the meter
s.meter;

//TODO:
//1. Experiment with guitar sounds. Done
//2. Build a UI. Partially done.
//3. Add MIDI pedal support. Partially Done
//4. Move reusable bits into classes or quarks. Done

//UI:
//a button/footswitch for in/out. This could either divert the in signal, or actually stop the granulator
//a b/f for randomized grains. GUI done
//a radio button/3 footswitches for octave

(
// Connect to MIDI devices.
MIDIClient.init;
MIDIIn.connectAll;

//MVC Models
//~modOnOff = NodeProxy.control(s, 1).source_(1);
//~modMix = NodeProxy.control(s, 1).source_(0.5);
~modRandomPitch = NodeProxy.control(s, 1).source_(0);
~modRate = NodeProxy.control(s, 1).source_(1);

//This object contains the MVC View creation functions
~viewMaker = AjmViewMaker.new;

//Program messages are when I push a footswitch on the FCB1010
MIDIdef.program(\programMessageReceiver, {
	arg val, chan, src;
	switch (val)
	{0}{
		//Toggle random pitched grains
		if
		(
			~modRandomPitch.source == 1,
			{ ~modRandomPitch.source = 0 },
			{ ~modRandomPitch.source = 1 }
		)
	}
	//Set the rate
	{1}{ ~modRate.source = 0.25; }
	{2}{ ~modRate.source = 0.5; }
	{3}{ ~modRate.source = 1.0;	};
});

//Set up the buffer to which sound is recorded
//It's 5 seconds and one channel
b = Buffer.alloc(s, s.sampleRate * 5, 1);

~ajmGranulator = AjmGranulator.new;

//Set up the three SynthDefs
~ajmGranulator.makeSynthDefs;

// Post things from inside the Synth
o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

//We need to create \granulator here (at least for now) because it involves
//values from the MVC models
//This SynthDef is the granulator
SynthDef.new(\granulator, {
	arg
	amp = 0.5,
	buf = 0,
	out = 0,
	atk = 1,
	rel = 1,
	gate = 1,
	sync = 1,
	dens = 40,
	baseDur = 0.05,
	durRand = 1,
	//rate = 1,
	//rateRand = 0.5.midiratio,
	pan = 0,
	panRand = 0,
	grainEnv = (-1),
	ptrBus = 0,
	ptrSampleDelay = 20000,
	ptrRandSamples = 5000,
	minPtrDelay = 1000;

	var sig, env, densCtrl, durCtrl, rateCtrl,
	panCtrl, ptr, ptrRand, totalDelay, maxGrainDur, rate, rateRand;

	//This envelope control the whole synth, not each grain
	//You can end the synth by setting gate = 0
	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);

	//TODO: Understand these 4 controls properly by reviewing both
	//Eli's granulation videos

	//The grain density control
	//If sync = 0, grains are sync'ed. Otherwise they're random
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	//The grain duration control, with some randomness
	durCtrl = baseDur * LFNoise1.ar(100).exprange(1 / durRand, durRand);
	//The rate control
	rate = ~modRate * 4.0;
	rateRand = (~modRandomPitch * 100).midiratio;
	rateCtrl = rate * LFNoise1.ar(100).exprange(1 / rateRand, rateRand);
	// This line is to send stuff to o for troubleshooting
	SendTrig.kr(Impulse.kr(4), 0, rate);

	//The pan control
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	//Implement a random delay in playback position
	ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
	totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	//Create a playback pointer
	ptr = In.ar(ptrBus, 1);
	ptr = ptr - totalDelay;
	ptr = ptr / BufFrames.kr(buf);

	//Calculate a maximum grain duration, to ensure we don't
	//bump into the recording point, where there's a discontinuity
	maxGrainDur = (totalDelay / rateCtrl) / SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		rateCtrl,
		ptr,
		2,
		panCtrl,
		grainEnv
	);

	//Scale the signal, add the envelope and output it
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

//Set up the two audio buffers, four groups to order Synths correctly,
//plus the three utility synths (all except the granulator)
~ajmGranulator.makeSynths(s, b);

//Use NodeProxy to create the Synth so that it can recieve notifications from models
~gran = NodeProxy.audio(s, 2).source_(\granulator).play.group(~grainGrp);

// This is the 20 granulator version.
// It create them but they all have the same pointer position, amplitude etc.
// How to spread pointers out and do the other stuff in the version below?
// ~g = 20.collect({
// 	arg n;
// 	NodeProxy.audio(s, 2).source_(\granulator).play.group(~grainGrp);
// });


//Create 1 granulator
// ~g = Synth.new(\granulator, [
// 	\amp, 0.5,
// 	\buf, b,
// 	\out, 0,
// 	\atk, 1,
// 	\rel, 1,
// 	\gate, 1,
// 	\sync, 0,
// 	\dens, exprand(20, 40),
// 	\baseDur, 0.08,
// 	\durRand, 1.5,
// 	\rate, 1,
// 	//\rateRand, 100.0.midiratio,
// 	\pan, 0,
// 	\panRand, 0.5,
// 	\grainEnv, -1,
// 	\ptrBus, ~ptrBus,
// 	\ptrSampleDelay, 1,
// 	\ptrRandSamples, 10000,
// 	\minPtrDelay, 1000,
// ], ~grainGrp);

//Create 20 granulators
// ~g = 20.collect({
// 	arg n;
// 	Synth(\granulator, [
// 		//This line means grains further from the recptr are quieter
// 		//so events seem to fade out
// 		\amp, n.linlin(0, 19, -3, -20).dbamp,
// 		\buf, b,
// 		\out, 0,
// 		\atk, 1,
// 		\rel, 1,
// 		\gate, 1,
// 		\sync, 0,
// 		\dens, exprand(20, 40),
// 		\baseDur, 0.08,
// 		\durRand, 1.5,
// 		\rate, 1,
// 		\rateRand, 0.5.midiratio,
// 		\pan, 0,
// 		\panRand, 0.5,
// 		\grainEnv, -1,
// 		\ptrBus, ~ptrBus,
// 		//This line spreads the five synths evenly to five different
// 		//playback points
// 		\ptrSampleDelay, n.linlin(0, 19, 1000, s.sampleRate * 2),
// 		\ptrRandSamples, 10000,
// 		\minPtrDelay, 1000,
// 	], ~grainGrp);
// });

// GUI using a grid layout

Window.closeAll;
w = Window.new("Granulator Stomp Box").layout_(
	GridLayout.rows(
		[
			StaticText().string_("Random Pitch On/Off"),
			~bRandom = ~viewMaker.makeOnOffButtonView(~modRandomPitch);
		],
		[
			StaticText().string_("Rate"),
			~bRate = ~viewMaker.makeSliderView(~modRate);
		]
	)
).front.alwaysOnTop_(true);
w.onClose = {
	~gran.set(\gate, 0); //Fade out the synth when the Window is closed
};

)

~modRandomPitch.source = 1;
~modRate.source = 0.5;
~modRate.source = 1.0;
~modRate.source = 2.0;

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