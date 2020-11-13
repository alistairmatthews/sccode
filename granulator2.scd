//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//display the meter
s.meter;

//TODO:
//0. Reuse AjmViewMaker and AjmMidiBinder
//0.5 Restructure to match the simple reverb
//1. Build a UI.
//2. Add MIDI pedal support. Partially done.
//3. Work out how to distribute grains over 3 octaves.
//4. Build a control to change the time period that grains are distributed over

//UI:
//a button/footswitch for in/out. This could either divert the in signal, or actually stop the granulator
//a b/f for randomized grains. GUI done
//a radio button/3 footswitches for octave

(

s.waitForBoot({

	//Set up the buffer to which sound is recorded
	//It's 5 seconds and one channel
	b = Buffer.alloc(s, s.sampleRate * 5, 1);

	//Create a granulator object
	~ajmGranulator = AjmGranulator.new;

	//Set up the three SynthDefs
	~ajmGranulator.makeSynthDefs;

	//Set up the two audio buffers, four groups to order Synths correctly,
	//plus the three utility synths (all except the granulator)
	~ajmGranulator.makeSynths(s, b).value;

	//MVC model
	~modInOut = 0;
	~modRandomOnOff = 0;
	~modRate = 1;

	//Functions to change controls
	~switchInOut = {
		if
		(
			~modInOut == 1,
			{
				~modInOut = 0;
				~micListener.set(\amp, 0);
				postln("Input bypassed");
			},
			{
				~modInOut = 1;
				~micListener.set(\amp, 1);
				postln("Input switched in");
			}
		)
	};

	~switchRandomOnOff = {
		if
		(
			~modRandomOnOff == 1,
			{
				~modRandomOnOff = 0;
				~g.do({ arg n; n.set(\rateRand, 0.0.midiratio)});
				postln("Random grain pitches: Off");
			},
			{
				~modRandomOnOff = 1;
				~g.do({ arg n; n.set(\rateRand, 100.0.midiratio)});
				postln("Random grain pitches: On");
			}
		)
	};

	~changeGrainRate = {
		arg newRate;
		~modRate = newRate;
		~g.do({ arg n; n.set(\rate, ~modRate)});
		postln("Grain rate: " + ~modRate);
	};

	//Midi Control
	// Connect to MIDI devices.
	MIDIClient.init;
	MIDIIn.connectAll;



	//Connect midi controls to functions
	MIDIdef.program(\programMessageReceiver, {
		arg val, chan, src;
		switch (
			val,
			0, {
				// Footswitch 1 has been pressed, Switch the listener in or out.
				~switchInOut.value; },
			1, {
				// Footswitch 2 has been pressed. Set the rate to 1.
				~changeGrainRate.value(1); },
			2, {
				// Footswitch 3 has been pressed, Set the rate to 2.
				~changeGrainRate.value(2); },
			3, {
				// Footswitch 4 has been pressed, Set the rate to 4.
				~changeGrainRate.value(4); },
			5, {
				// Footswitch 6 has been pressed. Switch randomness in or out.
				~switchRandomOnOff.value;
			}
		);
	});


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
	// 	\rateRand, 100.0.midiratio,
	// 	\pan, 0,
	// 	\panRand, 0.5,
	// 	\grainEnv, -1,
	// 	\ptrBus, ~ptrBus,
	// 	\ptrSampleDelay, 1,
	// 	\ptrRandSamples, 10000,
	// 	\minPtrDelay, 1000,
	// ], ~grainGrp);

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
			//This line spreads the twenty synths evenly to twenty different
			//playback points
			\ptrSampleDelay, n.linlin(0, 19, 1000, s.sampleRate * 2),
			\ptrRandSamples, 10000,
			\minPtrDelay, 1000,
		], ~grainGrp);
	});




});


)


~g.do({ arg n; n.set(\rateRand, 0.0.midiratio)});
~g.do({ arg n; n.set(\rateRand, 0.5.midiratio)});
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