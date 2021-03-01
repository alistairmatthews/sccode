(

s.waitForBoot({

	~ajmGranulator = AjmGranulator.new();
	~ajmSimpleReverb = AjmSimpleReverb.new();

	~patchCable1 = Bus.audio(s, 1);

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

	~ajmSimpleReverb.makeSynth(0, ~patchCable1);
	~ajmGranulator.wireUp(~patchCable1);
	~ajmGranulator.makeGranulators(0, 20);

});

)

~ajmGranulator.soundBuffer.plot();