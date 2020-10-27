// TODO: Find out why the first input is bus 2.
// For the focusrite 2i4 there are 4 outputs (0 - 3) so the first input is 4 right?
// Does SC always create 2 outputs by default? That's not a bad thing of course.

(

//TODO: Midi control
//TODO: fade out
//TODO: OnOff is an in/out, so reverb dies away naturally

//Create the SynthDef, using FreeVerb
// Post things from inside the Synth
//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);
s.waitForBoot({
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
});

//MVC Model

//Model properties
~revModel = Event.new;
~revModel.onOff = 0; //Reverb in/out
~revModel.mix = 0.5; //Mix of effect
~revModel.room = 0.5; //Room size
~revModel.damp = 0.5; //HF damping
~revModel.revSynth = Synth(\reverbstompbox, [
	\onOff, 0,
	\mix, ~revModel.mix,
	\room, ~revModel.room,
	\damp, ~revModel.damp
]);

//Call this function to change any value in the model
~setValueFunction = {
	arg key, value;
	~revModel [key] = value;
	~revModel.changed(key, value); //call changed to notify dependants of changes
};

//MVC View

//Create the window
~win = Window.new("myWindow", Rect(100, 100, 400, 140));

//Create the on/off button
~bOnOff = Button(~win, Rect(10, 10, 40, 40))
.states_([["Off"], ["On"]])
.value_(~revModel.onOff)
.action_({
	arg view;
	~setValueFunction.value(\onOff, view.value);
});

//Create the mix static text label
~labelMix = StaticText.new(~win, Rect(60, 20, 100, 20))
.string_("Mix:");
//Create the mix slider
~slMix = Slider.new(~win, Rect(150, 20, 180, 20))
.value_(~revModel.mix)
.action_({
	arg view;
	~setValueFunction.value(\mix, view.value);
});
//Create the mix number box
~nbMix = NumberBox.new(~win, Rect(340, 20, 44, 20))
.value_(~revModel.mix)
.action_({
	arg view;
	~setValueFunction.value(\mix, view.value);
});

//Create the room static text label
~labelRoom = StaticText.new(~win, Rect(60, 60, 100, 20))
.string_("Room:");
//Create the room slider
~slRoom = Slider.new(~win, Rect(150, 60, 180, 20))
.value_(~revModel.room)
.action_({
	arg view;
	~setValueFunction.value(\room, view.value);
});
//Create the room number box
~nbRoom = NumberBox.new(~win, Rect(340, 60, 44, 20))
.value_(~revModel.room)
.action_({
	arg view;
	~setValueFunction.value(\room, view.value);
});

//Create the HF Damping static text label
~labelRoom = StaticText.new(~win, Rect(60, 100, 100, 20))
.string_("HF Damping:");
//Create the damp slider
~slDamp = Slider.new(~win, Rect(150, 100, 180, 20))
.value_(~revModel.damp)
.action_({
	arg view;
	~setValueFunction.value(\damp, view.value);
});
//Create the damp number box
~nbDamp = NumberBox.new(~win, Rect(340, 100, 44, 20))
.value_(~revModel.damp)
.action_({
	arg view;
	~setValueFunction.value(\damp, view.value);
});

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
			~bOnOff.value_(val);
			//Turn on or off the reverb
			~revModel.revSynth.set(\onOff, val);
		},
		\mix, {
			//update views
			~nbMix.value_(val);
			~slMix.value_(val);
			//Set the mix level on the reverb
			~revModel.revSynth.set(\mix, val);
		},
		\room, {
			//update views
			~nbRoom.value_(val);
			~slRoom.value_(val);
			//Set the room size on the reverb
			~revModel.revSynth.set(\room, val);
		},
		\damp, {
			//update views
			~nbDamp.value_(val);
			~slDamp.value_(val);
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

)

//Test changes
~setValueFunction.value(\onOff, 0);
~setValueFunction.value(\onOff, 1);
~setValueFunction.value(\mix, 0.25);
~setValueFunction.value(\room, 0.25);
~setValueFunction.value(\damp, 0.25);