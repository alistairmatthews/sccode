//Select the ASIO driver when you boot the server?
//Otherwise the MME driver is selected and latency is too slow.

(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;
)

// TODO: Find out why the first input is bus 2.
// For the focusrite 2i4 there are 4 outputs (0 - 3) so the first input is 4 right?
// Does SC always create 2 outputs by default? That's not a bad thing of course.

//TODO: how to close the synth and everything when the window is closed?


(
// Connect to MIDI devices.
MIDIClient.init;
MIDIIn.connectAll;

//MVC Models
~modOnOff = NodeProxy.control(s, 1).source_(1);
~modMix = NodeProxy.control(s, 1).source_(0.5);
~modRoom = NodeProxy.control(s, 1).source_(0.5);
~modDamp = NodeProxy.control(s, 1).source_(0.5);

//MVC View creation functions
~makeOnOffButtonView = {
	arg model;
	var view, controller;

	view = Button()
	.states_([
		["Off", Color.black],
		["On", Color.red]
	])
	.action_({
		arg but;
		model.source = but.value;
	})
	.value_(model.source);

	//Create a controller for this view
	controller = SimpleController(model).put(\source, {
		arg obj, what, args;
		defer { view.value = args[0] };
	});

	view.onClose = { controller.remove };
};

~makeSliderView = {
	arg model;
	var view, controller;

	view = Slider()
	.orientation_(\horizontal)
	.background_(Color(1,0.5,0))
	.thumbSize_(40)
	.action_({
		arg slider;
		slider.value.postln; //Lose this line?
		model.source = slider.value;
	})
	.value_(model.source);

	//Create the controller for this view
	controller = SimpleController(model).put(\source, {
		arg obj, what, args;
		defer { view.value = args[0] };
	});

	view.onClose = { controller.remove };
};

//Program messages are when I push a footswitch on the FCB1010
MIDIdef.program(\programMessageReceiver, {
	arg val, chan, src;
	if(
		val == 0, //This responds only to switch 1 on the FCB1010
		{
			if
			(
				~modOnOff.source == 1,
				{ ~modOnOff.source = 0 },
				{ ~modOnOff.source = 1 }
			)
		}
	)
});


// //Control change messages are when I alter a continuous pedal on the FCB1010
MIDIdef.cc(\ccMessageReceiver, {
 	arg val, num, chan, src;
	if(
		chan == 1, //This will respond to the FCB1010 left exp pedal
		{ ~modMix.source = val.linlin(1, 127, 0, 1) },
		{ ~modRoom.source = val.linlin(1, 127, 0, 1) } //All other cc messages set the room size
	)
});

// Post things from inside the Synth
//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

SynthDef(\reverbstompbox, {
	arg outBus = 0, inBus = 2;
	//TODO: how to not hardcode the busses?
	var input, sig;

	//Get the input from the specified bus, mono
	input = In.ar(inBus, 1);

	// This line is to send stuff to o for troubleshooting
	//SendTrig.kr(Impulse.kr(4), 0, ~modRoom.kr(1));

	//mix in the reverb
	sig = FreeVerb.ar(
		input,
		min(~modMix, ~modOnOff),
		~modRoom,
		~modDamp
	);

	//Output the reverb'ed signal to the specified bus
	Out.ar(outBus, sig);
}).add;

//Use NodeProxy to create the Synth so that it can recieve notifications from models
x = NodeProxy.audio(s, 2).source_(\reverbstompbox).play;

// GUI using a grid layout

Window.closeAll;
w = Window.new("Reverb Stomp Box").layout_(
	GridLayout.rows(
		[
			StaticText().string_("On/Off"),
			~bOnOff = ~makeOnOffButtonView.(~modOnOff);
		],
		[
			StaticText().string_("Mix:"),
			~sMix = ~makeSliderView.(~modMix);
		],
		[
			StaticText().string_("Room size:"),
			~sRoom = ~makeSliderView.(~modRoom);
		],
		[
			StaticText().string_("HF Dampening:"),
			~sDamp = ~makeSliderView.(~modDamp);
		]
	)
).front.alwaysOnTop_(true);
)

