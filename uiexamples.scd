//Experiments in GUIs based on chap 10 of the SC book

(
//This version has no MVC concept. See below for an MVC version

//Values for amplitude and speed
~amp = 0.5;
~speed = 1.0;

//Create the window
~win = Window.new;
~win.setInnerExtent(370, 72);
~win.front;

// Create the play button
~playButton = Button(~win, Rect(4, 4, 40, 56));
~playButton.states = [["Play", Color.white, Color.green(0.4)], ["Stop", Color.white, Color.red]];
~playButton.action = {
	arg view;
	"New value is %\n".postf(view.value);
	if (view.value == 1,
		{~node = Synth(\bufPlay, [\buf, ~buf])}, //create and play the synth
		{~node.free; ~node = nil;} //Destroy the synth
	)
};

//Create the amp label
StaticText(~win, Rect(56, 4, 50, 25)).align_(\right).string_("Amp:");
//Create the amp slider
~ampSlider = Slider(~win, Rect(110, 4, 200, 25))
.value_(~amp)
.action_({
	arg view;
	~amp = view.value;
	~node.set(\amp, ~amp);
});

//Create the speed label
StaticText(~win, Rect(56, 32, 50, 25)).align_(\right).string_("Speed:");
//Create the speed slider. Use a ControlSpec to map the value of the slider to an exponential value to save
~speedSpec = ControlSpec(1/8, 8, \exp);
~speedSlider = Slider(~win, Rect(110, 32, 200, 25))
.value_(~speedSpec.unmap(~speed))
.action_({
	arg view;
	~speed = ~speedSpec.map(view.value);
	~node.set(\speed, ~speed);
});

//Create the synthdef. This one just plays a soundfile with a variable amplitude and speed
s.waitForBoot({
	SynthDef(\bufPlay, {
		arg buf, amp = 1.0, speed = 1.0;
		Out.ar(
			0,
			Pan2.ar(
				PlayBuf.ar(1, buf, speed * BufRateScale.kr(buf), loop: 1) * amp;
			)
		)
	}).add;
	~buf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
});

~buf.plot;
)

(
//This is the MVC pattern version

//Model
//Create the model from an SC event
~model = Event.new;
~model.isPlaying = 0; //1 = playing, 0 = stopped
~model.amp = 0.5;
~model.speed = 1.0;
//Call this function to change any value in the model
~setValueFunction = {
	arg key, value;
	~model [key] = value;
	~model.changed(key, value); //call changed to notify dependants of changes
};

//View
//Create the window
~win = Window.new("myWindow", Rect(100, 100, 328, 100));
//Create the play button
~playButton = Button(~win, Rect(4, 4, 40, 56))
.states_([["Play", Color.white, Color.green(0.4)], ["Stop", Color.white, Color.red]])
.value_(~model.isPlaying)
.action_({
	arg view;
	~setValueFunction.value(\isPlaying, view.value);
});
//Create the amp number box
~ampNumBox = NumberBox.new(~win, Rect(60, 20, 44, 20))
.value_(~model.amp)
.action_({
	arg view;
	~setValueFunction.value(\amp, view.value)
});
//Create the amp slider
~ampSlider = Slider.new(~win, Rect(108, 20, 200, 20))
.value_(~model.amp)
.action_({
	arg view;
	~setValueFunction.value(\amp, view.value)
});
//Create the amp level indicator. No need for an action because it just displays.
~ampLevel = LevelIndicator(~win, Rect(312, 20, 5, 20))
.value_(~model.amp)
.warning_(0.8)
.critical_(0.9);
//Create the speed number box
~speedNumBox = NumberBox.new(~win, Rect(60, 50, 44, 20))
.value_(~model.speed)
.action_({
 	arg view;
	~setValueFunction.value(\amp, view.value)
});
//Create the speed slider
~speedSpec = ControlSpec(1/8, 8, \exp); //This is to map an exponential range to the linear slider
~speedSlider = Slider.new(~win, Rect(108, 50, 200, 20))
.value_(~speedSpec.unmap(~model.speed))
.action_({
	arg view;
	~setValueFunction.value(\speed, ~speedSpec.map(view.value))
});
//Create the speed level indicator
~speedLevel = LevelIndicator(~win, Rect(312, 50, 5, 20))
.value_(~speedSpec.unmap(~model.speed))
.warning_(0.8)
.critical_(0.9);
//Complete the window
~win.front;
~win.onClose_({ //remove the synth and the model dependency
	~model.removeDependant(~updater);
	~node.free;
	~node = nil;
});

//Updater or Controller
~updater = {
	arg theChanger, what, val;
	switch (
		what,
		\amp, {
			//update views
			~ampNumBox.value_(val);
			~ampSlider.value_(val);
			~ampLevel.value_(val);
			//change the amplitude of the synth
			~node.set(\amp, val);
		},
		\isPlaying, {
			//update views
			~playButton.value_(val);
			if (val == 1,
				{
					//create and play the synth
					~node = Synth(\bufPlay,
						[\buf, ~buf, \amp, ~model.amp, \speed, ~model.speed]
					)
				},
				{~node.free; ~node = nil;} //Destroy the synth
			)
		},
		\speed, {
			//update views
			~speedNumBox.value_(val);
			~speedSlider.value_(~speedSpec.unmap(val));
			~speedLevel.value_(~speedSpec.unmap(val));
			//set the speed of the synth
			~node.set(\speed, val);
		}
	);
};
~model.addDependant(~updater);

//Create the synthdef. This one just plays a soundfile with a variable amplitude and speed
s.waitForBoot({
	SynthDef(\bufPlay, {
		arg buf, amp = 1.0, speed = 1.0;
		Out.ar(
			0,
			Pan2.ar(
				PlayBuf.ar(1, buf, speed * BufRateScale.kr(buf), loop: 1) * amp;
			)
		)
	}).add;
	~buf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
});


)

~setValueFunction.value(\amp, 0.4);
~setValueFunction.value(\isPlaying, 1);
~setValueFunction.value(\isPlaying, 0);
~setValueFunction.value(\speed, 1);
~setValueFunction.value(\speed, 0.5);
~setValueFunction.value(\speed, 2);
~setValueFunction.value(\speed, 4);

