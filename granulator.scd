//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//TODO:
//1. If you want to reuse the granulator elsewhere, put the synths in a separate class.
//2. Work out how to distribute grains over 3 octaves.
//3. Build a control to change the time period that grains are distributed over

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

		//This envelope controls the whole synth, not each grain
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
	~granModel.rateRand = 0;
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
	~ajmViewMaker.makeSliderGroup(\rate, "Rate:", 60, 20, 0.5, 4, \exp);

	//Create the random rate slider group
	~ajmViewMaker.makeSliderGroup(\rateRand, "Random:", 60, 60, 0.01, 100, \exp);

	//Clean up when the window is closed
	~win.onClose_({
		//remove the synth and the model dependency
		~granModel.removeDependant(~granController);
		//Stop the granulator by closing the gate
		~g.do({ arg n; n.set(\gate, 0)});
		//Remove the midi responders
		~ajmMidiBinder.unbind;
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
		switch (what,
			\inOut, {
				//Set the listener to record or not
				~micListener.set(\amp, val);
			},
			\rateRand, {
				//Set the random rate on the granulator but remember to use midiratio
				~g.do({ arg n; n.set(what, val.midiratio)});
			},
			{
				//For all other properties, set the value on the granulator
				~g.do({ arg n; n.set(what, val)}); }
		);
	};
	~granModel.addDependant(~granController);

	//Midi Control
	~ajmMidiBinder = AjmMidiBinder.new(~granModel);

	//Bind footswitch 1 to the In/Out property of the model
	~ajmMidiBinder.bindFootSwitch(0, \inOut);

	//Bind footswitch 2 to set the rate value to 0.5 (one octave down)
	~ajmMidiBinder.bindFootSwitch(1, \rate, 0.5);

	//Bind footswitch 3 to set the rate value to 1 (no pitch shift)
	~ajmMidiBinder.bindFootSwitch(2, \rate, 1);

	//Bind footswitch 4 to set the rate value to 2 (one octave up)
	~ajmMidiBinder.bindFootSwitch(3, \rate, 2);

	//Bind footswitch 5 to set the rate value to 4 (two octaves up)
	~ajmMidiBinder.bindFootSwitch(4, \rate, 4);

	//Bind footswitch 6 to set the rate randomization value to 0.01. A steady pitch
	~ajmMidiBinder.bindFootSwitch(5, \rateRand, 0.01);

	//Bind footswitch 7 to set the rate randomization value to 1.
	~ajmMidiBinder.bindFootSwitch(6, \rateRand, 1);

	//Bind footswitch 8 to set the rate randomization value to 50. Mayhem.
	~ajmMidiBinder.bindFootSwitch(7, \rateRand, 50);

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
	~micListener = Synth(\micListener, [\in, 0, \out, ~micBus, \amp, ~granModel.inOut], ~micGrp);
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
			\rate, ~granModel.rate, //TODO: set this from the model
			\rateRand, ~granModel.rateRand.midiratio,
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

//Test In/Out
~setValueFunction.value(\inOut, 0);
~setValueFunction.value(\inOut, 1);
//Test rate
~setValueFunction.value(\rate, 0.5);
~setValueFunction.value(\rate, 1);
~setValueFunction.value(\rate, 2);
~setValueFunction.value(\rate, 4);
//Test random rate
~setValueFunction.value(\rateRand, 0.01);
~setValueFunction.value(\rateRand, 5);
~setValueFunction.value(\rateRand, 50);

//Stop the granulator by closing the gate
~g.do({ arg n; n.set(\gate, 0)});

//Testing the content of the buffer
b.plot;
s.defaultGroup.deepFree;
b.play;