// TODO: Find out why the first input is bus 2.
// For the focusrite 2i4 there are 4 outputs (0 - 3) so the first input is 4 right?
// Does SC always create 2 outputs by default? That's not a bad thing of course.

(

//TODO: put this into a separate class for reuse in different patches
//TODO: then this file just demos that class.
//TODO: fade out
//TODO: OnOff is an in/out, so reverb dies away naturally

s.waitForBoot({

	~ajmSimpleReverb = AjmSimpleReverb.new();

	//~ajmSimpleReverb.makeSynthDef();

	//Create the SynthDef, using FreeVerb
	//This is for posting things from inside the Synth
	//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

	/*SynthDef(\reverbstompbox, {
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
	}).add;*/

	//MVC Model

	//Model properties
	//~revModel = ~ajmSimpleReverb.revModel;
	/*revModel.onOff = 0; //Reverb in/out
	~revModel.mix = 0.87; //Mix of effect
	~revModel.room = 0.5; //Room size
	~revModel.damp = 0.5; //HF damping*/

	//Call this function to change any value in the model
	//~setValueFunction = ~ajmSimpleReverb.setValueFunction;
	~setValueFunction = {
		arg key, value;
		postln("in ~setValueFunction outside the class. Key is " + key + "Value is" + value);
		~ajmSimpleReverb.revModel [key] = value;
		~ajmSimpleReverb.revModel.changed(key, value); //call changed to notify dependants of changes
	};

	//MVC View
	//~ajmSimpleReverb.makeGUI;

	//Create the window
	/*~win = Window.new("FreeVerb", Rect(100, 100, 420, 140));

	~ajmViewMaker = AjmViewMaker.new(~win, ~revModel, Color.green(0.6));

	//Create the on/off button
	~ajmViewMaker.makeButton(\onOff, "On", "Off", 10, 10);

	//Create the mix slider group
	~ajmViewMaker.makeSliderGroup(\mix, "Mix:", 60, 20);

	//Create the room slider group
	~ajmViewMaker.makeSliderGroup(\room, "Room:", 60, 60);

	//Create the HF Damping slider group
	~ajmViewMaker.makeSliderGroup(\damp, "HF Damping:", 60, 100);

	//Clean up when the window is closed
	~win.onClose_({
		//Clean up MIDI binding
		MIDIdef.freeAll;
		//remove the synth and the model dependency
		~revModel.removeDependant(~revController);
		~revSynth.free;
		~revModel = nil;
	});
	~win.front;*/

	//MVC Controller
	~revController = {
		arg theChanger, what, val;
		postln("In ~revController. theChanger: " + theChanger + "what: " + what + "val: " + val);
		~ajmSimpleReverb.viewMaker.updateControls(what, val);
		~ajmSimpleReverb.revSynth.set(what, val);
	};
	~ajmSimpleReverb.revModel.addDependant(~revController);
	//This line doesn't work and returns an error:
	//~ajmSimpleReverb.revModel.addDependant(~ajmSimpleReverb.blahcontroller());

	//MIDI Control
	~ajmMidiBinder = AjmMidiBinder.new(~ajmSimpleReverb.revModel);

	//Bind footswitch 1 to the On/Off property of the model
	~ajmMidiBinder.bindFootSwitch(0, \onOff);

	//Bind expression pedal A to the Mix property of the model
	//and pedal B to the Room property
	~ajmMidiBinder.bindExpressionPedals(\mix, \room);

	//Create the synth
	~ajmSimpleReverb.makeSynth();
	/*~revSynth = Synth(\reverbstompbox, [
		\onOff, 0,
		\mix, ~ajmSimpleReverb.revModel.mix,
		\room, ~ajmSimpleReverb.revModel.room,
		\damp, ~ajmSimpleReverb.revModel.damp
	]);*/

});

)

//Test changes
~ajmSimpleReverb.setValueFunction(\onOff, 1);
~setValueFunction.value(\onOff, 0);
~setValueFunction.value(\onOff, 1);
~setValueFunction.value(\mix, 0.5);
~setValueFunction.value(\room, 0.25);
~setValueFunction.value(\damp, 0.25);