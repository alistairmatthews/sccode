//Select the ASIO driver when you boot the server?
//Otherwise the MME driver is selected and latency is too slow.

(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;
)

\\ TODO: Find out why the first input is bus 2.
\\ For the focusrite 2i4 there are 4 outputs (0 - 3) so the first input is 4 right?
\\ Does SC always create 2 outputs by default? That's not a bad thing of course.

(
SynthDef("reverbstompbox", {
	arg outBus = 0, inBus, mix = 0.5, room = 0.5, damp = 0.5;
	var input;

	//Get the input from the specified bus, mono
	input = In.ar(inBus, 1);

	//Output the reverb'ed signal to the sepcified bus
	Out.ar(outBus, FreeVerb.ar(
		input,
		mix,
		room,
		damp
	));
}).add;
)

// GUI using a grid layout
(
//TO DO: tie these to the arguments on reverbstompbox
w = Window.new("Reverb Stomp Box").layout_(
	GridLayout.rows(
		[
			StaticText().string_("Mix:"),
			~sMix = Slider().orientation_(\horizontal)
		],
		[
			StaticText().string_("Room size:"),
			~sRoom = Slider().orientation_(\horizontal)
		],
		[
			StaticText().string_("HF Dampening:"),
			~sDamp = Slider().orientation_(\horizontal)
		]
	)
).front;
)


//Run the stompbox.
//For many soundcards, the first two buses will be outputs. Try the third one.
// TODO: can we avoid hard-coding the input bus here?
x = Synth.new("reverbstompbox", [\inBus, 2, \mix , 0.5, \room, 1.0, \damp, 0.9]);
x = Synth.new("reverbstompbox", [\inBus, 2, \mix , 1.0, \room, 0.2, \damp, 0.1]);
x.free;