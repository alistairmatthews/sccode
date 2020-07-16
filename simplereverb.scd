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
	var input, sig;

	//Get the input from the specified bus, mono
	input = In.ar(inBus, 1);

	//mix in the reverb
	sig = FreeVerb.ar(
		input,
		mix, //If you can hear any pops when you make big discrete changes to controls, use .lag() here
		room,
		damp
	);

	//Output the reverb'ed signal to the sepcified bus
	Out.ar(outBus, sig);
}).add;
)

// GUI using a grid layout
(
Window.closeAll;
w = Window.new("Reverb Stomp Box").layout_(
	GridLayout.rows(
		[
			StaticText().string_("On/Off"),
			~bOnOff = Button()
			.states_([
				["Off", Color.black],
				["On", Color.red]
			])
			.action_({
				arg but;
				if(
					but.value == 1,
					{
						//Run the stompbox!
						//For many soundcards, the first two buses will be outputs. Try the third one.
						//We have to register it with the node watcher so that we can check if it
						//exists
						x = Synth.new("reverbstompbox",
							[\inBus, 2, \mix , ~sMix.value, \room, ~sRoom.value, \damp, ~sDamp.value]
						).register;
					},
					{
						//Stop the stompbox
						x.free;
					}
				);
			})
		],
		[
			StaticText().string_("Mix:"),
			~sMix = Slider().orientation_(\horizontal)
			.background_(Color(1,0.5,0))
			.thumbSize_(40)
			.action_({
				arg slider;
				slider.value.postln; //Lose this line?
				if(
					x.isPlaying, //We can call this because the synth is registered with the node watcher
					{x.set(\mix, slider.value)}
				);
			})
		],
		[
			StaticText().string_("Room size:"),
			~sRoom = Slider().orientation_(\horizontal)
			.background_(Color(0,1,0.5))
			.thumbSize_(40)
			.action_({
				arg slider;
				if(
					x.isPlaying,
					{x.set(\room, slider.value)}
				);
			})
		],
		[
			StaticText().string_("HF Dampening:"),
			~sDamp = Slider().orientation_(\horizontal)
			.background_(Color(0.5,0,1))
			.thumbSize_(40)
			.action_({
				arg slider;
				if(
					x.isPlaying,
					{x.set(\damp, slider.value)}
				);
			})
		]
	)
).front.alwaysOnTop_(true);
)