AjmSimpleReverb {

	//TODO: OnOff is an in/out, so reverb dies away naturally

	//The MVC model for the reverb
	var <>model;
	//The class that builds the GUI
	var <>viewMaker;
	//The synth
	var <>revSynth;
	//The MVC controller
	var revController;

	*new {
		//call the superclass new, then this class's init
		^super.new.init();
	}

	init {
		//Set up the MVC model
		model = Event.new;
		model.onOff = 0; //Reverb in/out
		model.mix = 0.87; //Mix of effect
		model.room = 0.5; //Room size
		model.damp = 0.5; //HF damping
		//Make the synth def
		this.makeSynthDef();
		//Make the GUI
		this.makeGUI();
		//Add the controller as a dependent of the model
		this.addTheDependant();
	}

	//Call this function to change any value in the model
	setValueFunction {
		arg key, value;
		model [key] = value;
		model.changed(key, value); //call changed to notify dependants of changes
	}

	//This method adds the MVC controller as a dependant of the model
	addTheDependant {
		//Note: I found that you can only add the controller
		//as a dependant if you create it as a function, not as a
		//method in this class. Otherwise, the controller is called
		//when you add it as a dependant and that causes an error.
		//It also doesn't seem to add correctly.
		revController = {
			arg theChanger, what, val;
			viewMaker.updateControls(what, val);
			revSynth.set(what, val);
		};
		model.addDependant(revController);
	}

	makeSynthDef {
		//In this method, make the synth def and send it to the server

		//This is for posting things from inside the Synth
		//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

		SynthDef(\reverbstompbox, {
			arg outBus = 0,
			inBus = 0,
			onOff = 0,
			mix = 0.5,
			room = 0.5,
			damp = 0.5;

			var input, sig;

			//Get the input from the specified bus, mono
			input = SoundIn.ar(inBus, 1);

			// This line is to send stuff to o for troubleshooting
			//SendTrig.kr(Impulse.kr(4), 0, ~modRoom.kr(1));

			//mix in the reverb
			sig = FreeVerb.ar(
				input,
				min(mix, onOff),
				room,
				damp
			);

			//Output the reverb'ed signal to the specified bus
			Out.ar(outBus, sig);
		}).add;
	}

	makeSynth {
		arg inputBus, outputBus;
		revSynth = Synth(\reverbstompbox, [
			\inBus, inputBus,
			\outBus, outputBus,
			\onOff, 0,
			\mix, model.mix,
			\room, model.room,
			\damp, model.damp
		]);
	}

	makeGUI {
		//Create the window
		~win = Window.new("FreeVerb", Rect(100, 100, 420, 140));

		//viewMaker = AjmViewMaker.new(~win, model, Color.green(0.6));
		viewMaker = AjmViewMaker.new(~win, this, Color.green(0.6));

		//Create the on/off button
		viewMaker.makeButton(\onOff, "On", "Off", 10, 10);

		//Create the mix slider group
		viewMaker.makeSliderGroup(\mix, "Mix:", 60, 20);

		//Create the room slider group
		viewMaker.makeSliderGroup(\room, "Room:", 60, 60);

		//Create the HF Damping slider group
		viewMaker.makeSliderGroup(\damp, "HF Damping:", 60, 100);

		//Clean up when the window is closed
		~win.onClose_({
			//Clean up MIDI binding
			MIDIdef.freeAll;
			//remove the synth and the model dependency
			model.removeDependant(revController);
			revSynth.free;
			model = nil;
		});
		~win.front;
	}

}