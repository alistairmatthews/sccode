//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//TODO:
//0. Reuse AjmViewMaker and AjmMidiBinder
//0.5 How to create slider groups with a range from 0.25 to 4 for the rate variable?
// and also to make it exponential
//1. Finish the UI.
//2. Add MIDI pedal support.
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

	//SynthDefs

	//This SynthDef reads the input signal, applies a volume and sends
	//it to a bus
	SynthDef.new(\micListener, {
		arg in = 0, out = 0, amp = 1;
		var sig;
		//Note: with SoundIn the first audio input is always 0
		sig = SoundIn.ar(in) * amp;
		Out.ar(out, sig);
	}).add;

	//This SynthDef generates the pointer that tells us where to
	//write the input signal.
	SynthDef.new(\pointer, {
		arg out = 0, buf = 0;
		var sig;
		sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
		Out.ar(out, sig);
	}).add;

	//This SynthDef reads the mic signal and pointer signal and uses them
	//to record sound into the buffer
	SynthDef.new(\soundRecorder, {
		arg ptrIn = 0, micIn = 0, buf = 0;
		var ptr, sig;
		ptr = In.ar(ptrIn, 1);
		sig = In.ar(micIn, 1);
		BufWr.ar(sig, buf, ptr);
	}).add;

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
		rate = 1,
		rateRand = 0.5.midiratio,
		pan = 0,
		panRand = 0,
		grainEnv = (-1),
		ptrBus = 0,
		ptrSampleDelay = 20000,
		ptrRandSamples = 5000,
		minPtrDelay = 1000;

		var sig, env, densCtrl, durCtrl, rateCtrl,
		panCtrl, ptr, ptrRand, totalDelay, maxGrainDur;

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
		rateCtrl = rate * LFNoise1.ar(100).exprange(1 / rateRand, rateRand);
		// This line is to send stuff to o for troubleshooting
		//SendTrig.kr(Impulse.kr(4), 0, amp);

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

	//MVC model
	~granModel = Event.new;
	~granModel.inOut = 0;
	~granModel.randomOnOff = 0;
	~granModel.rate = 1;

	//Call this function to change any value in the model
	~setValueFunction = {
		arg key, value;
		~granModel [key] = value;
		~granModel.changed(key, value); //call changed to notify dependants of changes
	};


	//MVC View

	//Create the window
	~win = Window.new("Granulator", Rect(100, 100, 420, 140));

	~ajmViewMaker = AjmViewMaker.new(~win, ~granModel, Color.magenta(0.6));

	//Create the in/out button
	~ajmViewMaker.makeButton(\inOut, "In", "Out", 10, 10);

	//Create the rate slider group
	~ajmViewMaker.makeSliderGroup(\rate, "Rate:", 60, 20);

	//Clean up when the window is closed
	~win.onClose_({
		//remove the synth and the model dependency
		~granModel.removeDependant(~granController);
		//Stop the granulator by closing the gate
		~g.do({ arg n; n.set(\gate, 0)});
		//Free the other synths
		~micListener.free;
		~pointer.free;
		~recorder.free;
		//close the groups
		~micGrp.free;
		~ptrGrp.free;
		~recGrp.free;
		~grainGrp.free;
		~granModel = nil;
	});
	~win.front;

	//MVC Controller
	~granController = {
		arg theChanger, what, val;
		~ajmViewMaker.updateControls(what, val);
		postln(theChanger);
		postln(what);
		postln(val);
		if (
			what == \inOut,
			{ ~micListener.set(\amp, val); },
			{ ~g.do({ arg n; n.set(what, val)}); }
		)
	};
	~granModel.addDependant(~granController);

	//Functions to change controls
	// ~switchInOut = {
	// 	if
	// 	(
	// 		~granModel.inOut == 1,
	// 		{
	// 			~granModel.inOut = 0;
	// 			~micListener.set(\amp, 0);
	// 			postln("Input bypassed");
	// 		},
	// 		{
	// 			~granModel.inOut = 1;
	// 			~micListener.set(\amp, 1);
	// 			postln("Input switched in");
	// 		}
	// 	)
	// };
	//
	// ~switchRandomOnOff = {
	// 	if
	// 	(
	// 		~granModel.randomOnOff == 1,
	// 		{
	// 			~granModel.randomOnOff = 0;
	// 			~g.do({ arg n; n.set(\rateRand, 0.0.midiratio)});
	// 			postln("Random grain pitches: Off");
	// 		},
	// 		{
	// 			~granModel.randomOnOff = 1;
	// 			~g.do({ arg n; n.set(\rateRand, 100.0.midiratio)});
	// 			postln("Random grain pitches: On");
	// 		}
	// 	)
	// };
	//
	// ~changeGrainRate = {
	// 	arg newRate;
	// 	~granModel.rate = newRate;
	// 	~g.do({ arg n; n.set(\rate, ~granModel.rate)});
	// 	postln("Grain rate: " + ~granModel.rate);
	// };

	//Midi Control
	// Connect to MIDI devices.
	MIDIClient.init;
	MIDIIn.connectAll;



	//Connect midi controls to functions
	/*MIDIdef.program(\programMessageReceiver, {
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
*/
	//Set up the two audio buffers, four groups to order Synths correctly,
	//plus the three utility synths (all except the granulator)
	//Set up the audio buses for the mic and pointer
	~micBus = Bus.audio(s, 1);
	~ptrBus = Bus.audio(s, 1);

	//Create groups to order the Synths
	//Any synth that reads from a bus must be downstream
	//from the synth that writes to that bus.
	~micGrp = Group.new;
	~ptrGrp = Group.after(~micGrp);
	~recGrp = Group.after(~ptrGrp);
	~grainGrp = Group.after(~recGrp);

	//Now we can set up the synths, placing each into the right group
	~micListener = Synth(\micListener, [\in, 0, \out, ~micBus], ~micGrp);
	~pointer = Synth(\pointer, [\buf, b, \out, ~ptrBus], ~ptrGrp);
	~recorder = Synth(\soundRecorder, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, b], ~recGrp);

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