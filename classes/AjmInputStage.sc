AjmInputStage {

	//This is an input stage that mixes two inputs to a mono out
	//and displays the two input levels

	//The MVC model for the input stage
	var <>model;
	//The MVC controller
	var inputController;
	//The class that builds the GUI (MVC View)
	var <>viewMaker;
	//The synth
	var <>inputStageSynth;

	*new {
		//call the superclass new, then this class's init
		^super.new.init();
	}

	init {
		//Set up the MVC model
		model = Event.new;
		model.leftMix = 0.5; //Mix from left input
		model.rightMix = 0.5; //Mix from right input
		//Make the synth def
		this.makeSynthDef();
		//Make the GUI
		this.makeGUI();
		//Add the controller as a dependant of the model
		this.addTheDependant();
	}

	//Call this function to change any value in the model
	setValueFunction {
		arg key, value;
		model [key] = value;
		model.changed(key, value); //call changed to notify dependants (the controller) of changes
	}

	makeGUI {
		//This implements the MVC view

		//Create the window
		~win = Window.new("Input Stage", Rect(100, 200, 380, 110));

		//Create the ViewMaker object that manages the GUI
		viewMaker = AjmViewMaker.new(~win, this, Color.blue(0.6));

		//Create the left input channel mix slider group
		viewMaker.makeSliderGroup(\leftMix, "Left Mix:", 10, 20);

		//Create the right input channel mix slider group
		viewMaker.makeSliderGroup(\rightMix, "Right Mix:", 10, 60);

		~win.onClose_({
			//Clean up MIDI binding
			MIDIdef.freeAll;
			//remove model dependency
			model.removeDependant(inputController);
			//Remove the synth
			inputStageSynth.free;
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
		inputController = {
			arg theChanger, what, val;
			viewMaker.updateControls(what, val);
			inputStageSynth.set(what, val);
		};
		model.addDependant(inputController);
	}

	makeSynthDef {

		//Make the synth def and send it to the server

		//This is for posting things from inside the Synth
		//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

		SynthDef(\ajsinputstage, {
			arg outBus = 0,
			leftMix = 0.5,
			rightMix = 0.5;

			var leftMixed, rightMixed;

			// Listen to the sound inputs.
			// Remember that passing 0 to SoundIn gets the first hardware input
			// even though the index of that input is usually 2.
			leftMixed = SoundIn.ar(0, leftMix);
			rightMixed = SoundIn.ar(1, rightMix);

			// This line is to send stuff to o for troubleshooting
			// SendTrig.kr(Impulse.kr(4), 0, ~modRoom.kr(1));
			
			Out.ar(outBus, Mix.ar([leftMixed, rightMixed]));
		}).add;
		
	}

	makeSynth {
		//Create the input stage synth from the SynthDef
		arg leftInputBus, rightInputBus, outputBus, parentGroup;
		inputStageSynth = Synth(\ajsinputstage, [
			\leftInBus, leftInputBus,
			\rightInBus, rightInputBus,
			\outBus, outputBus,
			\leftMix, model.leftmix,
			\rightMix, model.rightmix
		], parentGroup); 
	}
	
}