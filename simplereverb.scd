// TODO: Find out why the first input is bus 2.
// For the focusrite 2i4 there are 4 outputs (0 - 3) so the first input is 4 right?
// Does SC always create 2 outputs by default? That's not a bad thing of course.

(

//TODO: Put midi control into its own class for reuse?
//TODO: fade out
//TODO: OnOff is an in/out, so reverb dies away naturally
//TODO: Order of boot is off so sometimes the synth node is not created right

s.waitForBoot({

	//Create the SynthDef, using FreeVerb
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


	//MVC Model

	//Model properties
	~revModel = Event.new;
	~revModel.onOff = 0; //Reverb in/out
	~revModel.mix = 0.87; //Mix of effect
	~revModel.room = 0.5; //Room size
	~revModel.damp = 0.5; //HF damping
	~revModel.revSynth = Synth(\reverbstompbox, [
		\onOff, 0,
		\mix, ~revModel.mix,
		\room, ~revModel.room,
		\damp, ~revModel.damp
	]);

	//Call this function to change any value in the model
	//TODO: is this function better stored as part of the model?
	~setValueFunction = {
		arg key, value;
		~revModel [key] = value;
		~revModel.changed(key, value); //call changed to notify dependants of changes
	};

	//MVC View

	//Create the window
	~win = Window.new("myWindow", Rect(100, 100, 420, 140));

	~ajmViewMaker = AjmViewMaker.new(~win, ~revModel);

	//Create the on/off button
	~ajmViewMaker.makeButton(\onOff, "On", "Off", 10, 10);

	//Create the mix static text label
	~ajmViewMaker.makeSliderGroup(\mix, "Mix:", 60, 20);

	//Create the room static text label
	~ajmViewMaker.makeSliderGroup(\room, "Room:", 60, 60);

	//Create the HF Damping static text label
	~ajmViewMaker.makeSliderGroup(\damp, "HF Damping:", 60, 100);

	//Clean up when the window is closed
	~win.onClose_({
		//remove the synth and the model dependency
		~revModel.removeDependant(~revController);
		~revModel.revSynth.free;
		~revModel = nil;
	});
	~win.front;

	//MVC Controller
	~revController = {
		arg theChanger, what, val;
		switch (
			what,
			\onOff, {
				//update views
				~ajmViewMaker.updateControls(\onOff, val);
				//Turn on or off the reverb
				~revModel.revSynth.set(\onOff, val);
			},
			\mix, {
				//update views
				~ajmViewMaker.updateControls(\mix, val);
				//Set the mix level on the reverb
				~revModel.revSynth.set(\mix, val);
			},
			\room, {
				//update views
				~ajmViewMaker.updateControls(\room, val);
				//Set the room size on the reverb
				~revModel.revSynth.set(\room, val);
			},
			\damp, {
				//update views
				~ajmViewMaker.updateControls(\damp, val);
				//Set the damping on the reverb
				~revModel.revSynth.set(\damp, val);
			},
		);
	};
	~revModel.addDependant(~revController);

	//MIDI Control
	MIDIClient.init;
	MIDIIn.connectAll;

	//Program messages are when I push a footswitch on the FCB1010
	MIDIdef.program(\programMessageReceiver, {
		arg val, chan, src;
		if(
			val == 0, //This responds only to switch 1 on the FCB1010
			{
				//the MIDI responder is in a different context to the main thread so you can't call ~setValueFunction
				//We need to call ~setValueFunction separately from the MIDI responder
				//To do that, use defer.
				defer {
					if
					(
						~revModel.onOff == 1,
						{ ~setValueFunction.value(\onOff, 0) },
						{ ~setValueFunction.value(\onOff, 1) }
					)
				}
			}
		)
	});

	//Control change messages are when I alter a continuous pedal on the FCB1010
	MIDIdef.cc(\ccMessageReceiver, {
		arg val, num, chan, src;
		defer {
			if(
				chan == 1, //This will respond to the FCB1010 left exp pedal
				{ ~setValueFunction.value(\mix, val.linlin(1, 127, 0, 1)) },
				{ ~setValueFunction.value(\room, val.linlin(1, 127, 0, 1)) } //All other cc messages set the room size
			)

		}
	});

});

)

//Test changes
~setValueFunction.value(\onOff, 0);
~setValueFunction.value(\onOff, 1);
~setValueFunction.value(\mix, 0.5);
~setValueFunction.value(\room, 0.25);
~setValueFunction.value(\damp, 0.25);