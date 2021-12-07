AjmGranulator {

	//This a live granular synth class with a GUI.
	//MIDI control is available
	////This is based on Eli Fieldsteels tutorial:
	//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

	//TODO:
	//1. If you want to reuse the granulator elsewhere, put the synths in a separate class.
	//2. Work out how to distribute grains over 3 octaves.
	//3. Build a control to change the time period that grains are distributed over

	//TODO: Review which of these variables should be public and read or write.
	//The MVC model for the granulator
	var <>model;
	//The class that builds the GUI (MVC View)
	var viewMaker;
	//The MVC controller
	var granController;
	//This buffer stores incoming sounds for creating grains from
	var <>soundBuffer;
	//This synth gets sound from the input
	var micListener;
	//This synth points to the bit of the buffer to record to.
	var pointer;
	//This synth records to the buffer
	var recorder;
	//Groups to order the synths
	var micGrp;
	var ptrGrp;
	var recGrp;
	var grainGrp;
	//This collection of synths are the grain players
	var <>granulators;
	//To free all granulator synths:
	// granulators.do({ arg n; n.set(\gate, 0)});

	*new {
		//call the superclass new, then this class's init
		^super.new.init();
	}

	init {
		//Set up the buffer
		soundBuffer = Buffer.alloc(Server.local, Server.local.sampleRate * 5, 1);
		//Make the SynthDefs
		this.makeSynthDefs();
		//Set up the MVC model
		model = Event.new;
		model.inOut = 0; //Switch the effect in or out
		model.rateRand = 0; //Sets how much randomness there is in each grain
		model.rate = 1; //Sets how fast to play back each grain. 1 means original speed/pitch
		//Make the GUI
		this.makeGUI();
		//Add the controller as a dependent of the model
		this.addTheDependant();
	}

	//Call this function to change any value in the model
	setValueFunction {
		arg key, value;
		model [key] = value;
		//call changed to notify dependants (the controller) of changes
		model.changed(key, value);
	}

	makeGUI {
		//This implements the MVC view

		//Create the window
		~win = Window.new("Granulator", Rect(100, 100, 420, 140));

		viewMaker = AjmViewMaker.new(~win, this, Color.magenta(0.6));

		//Create the in/out button
		viewMaker.makeButton(\inOut, "In", "Out", 10, 10);

		//Create the rate slider group
		viewMaker.makeSliderGroup(\rate, "Rate:", 60, 20, 0.5, 4, \exp);

		//Create the random rate slider group
		viewMaker.makeSliderGroup(\rateRand, "Random:", 60, 60, 0.01, 100, \exp);

		//Clean up when the window is closed
		~win.onClose_({
			//Stop the granulators by closing the gate
			granulators.do({ arg n; n.set(\gate, 0)});
			//Remove the midi bindings
			MIDIdef.freeAll;
			//remove the synth and the model dependency
			model.removeDependant(granController);
			//Free the other synths
			micListener.free;
			pointer.free;
			recorder.free;
			//close the groups
			micGrp.free;
			ptrGrp.free;
			recGrp.free;
			grainGrp.free;
			model = nil;
		});
		~win.front;

	}

	//This method adds the MVC controller as a dependant of the model
	addTheDependant {
		//Note: I found that you can only add the controller
		//as a dependant if you create it as a function, not as a
		//method in this class. Otherwise, the controller is called
		//when you add it as a dependant and that causes an error.
		//It also doesn't seem to add correctly.
		granController = {
			arg theChanger, what, val;
			viewMaker.updateControls(what, val);
			switch (what,
				\inOut, {
					//Set the listener to record or not
					micListener.set(\amp, val);
				},
				\rateRand, {
					//Set the random rate on the granulator but remember to use midiratio
					granulators.do({ arg n; n.set(what, val.midiratio)});
				},
				{
					//For all other properties, set the value on the granulator
					granulators.do({ arg n; n.set(what, val)}); }
			);
		};
		model.addDependant(granController);
	}

	makeSynthDefs {

		//Make the synthdefs and send them to the server.

		//This SynthDef reads the input signal, applies a volume and sends
		//it to a bus
		SynthDef.new(\micListener, {
			arg in = 0, out = 0, amp = 1;
			var sig;
			//Get sound from the specified input bus
			sig = In.ar(in, 1) * amp;
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

		//This is for posting things from inside the Synth
		//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

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
			//The pan control
			panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

			// This line is to send stuff to o for troubleshooting
			//SendTrig.kr(Impulse.kr(4), 0, amp);

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

	}

	wireUp {
		//This method sets up the two audio buffers, four groups to order Synths correctly,
		//plus the three utility synths (all except the granulator)

		arg inputBus, //The bus to listen to
		parentGroup; //The group to place sub groups and synths in

		//Set up the audio buses for the mic and pointer
		~micBus = Bus.audio(Server.local, 1);
		~ptrBus = Bus.audio(Server.local, 1);

		//Create groups to order the Synths
		//Any synth that reads from a bus must be downstream
		//from the synth that writes to that bus.
		micGrp = Group.head(parentGroup);
		ptrGrp = Group.after(micGrp);
		recGrp = Group.after(ptrGrp);
		grainGrp = Group.after(recGrp);

		//Now we can set up the synths, placing each into the right group
		micListener = Synth(
			\micListener,
			[\in, inputBus, \out, ~micBus, \amp, model.inOut],
			micGrp
		);
		pointer = Synth(
			\pointer,
			[\buf, soundBuffer, \out, ~ptrBus],
			ptrGrp
		);
		recorder = Synth(
			\soundRecorder,
			[\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, soundBuffer],
			recGrp
		);
	}

	makeGranulators {
		arg outputBus, howMany;

		//Create granulators. The number is specified in howMany
		granulators = howMany.collect({
			arg n;
			Synth(\granulator, [
				//This line means grains further from the recptr are quieter
				//so events seem to fade out
				\amp, n.linlin(0, 19, -3, -20).dbamp,
				\buf, soundBuffer,
				\out, outputBus,
				\atk, 1,
				\rel, 1,
				\gate, 1,
				\sync, 0,
				\dens, exprand(20, 40),
				\baseDur, 0.08,
				\durRand, 1.5,
				\rate, model.rate,
				\rateRand, model.rateRand.midiratio,
				\pan, 0,
				\panRand, 0.5,
				\grainEnv, -1,
				\ptrBus, ~ptrBus,
				//This line spreads the twenty synths evenly to twenty different
				//playback points
				\ptrSampleDelay, n.linlin(0, 19, 1000, Server.local.sampleRate * 2),
				\ptrRandSamples, 10000,
				\minPtrDelay, 1000,
			], grainGrp);
		});

	}

}