AjmInputStage {

	//This is an input stage that mixes two inputs to a mono out
	//and displays the two input levels

	//The synth
	var <>inputSynth;

	*new {
		//call the superclass new, then this class's init
		^super.new.init();
	}

	init {
		//TODO: Set up the model
		//Make the synth def
		this.makeSynthDef();
		//TODO: Make the GUI
		//TODO Add the controller as a dependant of the model
	}

	makeSynthDef {

		//Make the synth def and send it to the server

		//This is for posting things from inside the Synth
		//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

		SynthDef(\inputStage, {
			arg leftInBus = 0,
			rightInBus = 1,
			outBus = 0,
			leftMix = 0.5,
			rightMix = 0.5;

			var leftMixed, rightMixed;

			leftMixed = SoundIn.ar(leftInBus, leftMix);
			rightMixed = SoundIn.ar(rightInBus, rightMix);

			// This line is to send stuff to o for troubleshooting
			//SendTrig.kr(Impulse.kr(4), 0, ~modRoom.kr(1));
			
			Out.ar(outBus, Mix.ar([leftMixed, rightMixed]));
		}).add;
		
	}
	
}