(

s.waitForBoot({

	~patchCable1 = Bus.audio(s, 1);

	~ajmGranulator = AjmGranulator.new();
	~ajmSimpleReverb = AjmSimpleReverb.new();

	//Granulator Midi Control
	~granMidiBinder = AjmMidiBinder.new(~ajmGranulator);
	//Bind footswitch 1 to the In/Out property of the model
	~granMidiBinder.bindFootSwitch(0, \inOut);

	//TODO: This seems to cause an infinite loop or something

	//MIDI Control
	//~revMidiBinder = AjmMidiBinder.new(~ajmSimpleReverb);
	//Bind footswitch 1 to the On/Off property of the model
	//~revMidiBinder.bindFootSwitch(1, \onOff);

	postln("The buffer number for the patch cable is" + ~patchCable1);

	//TODO: You've got to order these correctly in the node tree, otherwise no sound

	~granGroup = Group.new();
	~ajmGranulator.wireUp(0, ~granGroup);
	~ajmGranulator.makeGranulators(~patchCable1, 20);
	~reverbGroup = Group.tail(s);
	~ajmSimpleReverb.makeSynth(~patchCable1, 1, ~reverbGroup);
	//TODO: This is causing the output to distort massively. ALl you can here are clicks
	//TODO: make sure the two above groups get removed when you close the windows.

});

)

~ajmGranulator.soundBuffer.plot();