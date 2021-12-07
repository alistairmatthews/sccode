(

s.waitForBoot({

	~patchCable1 = Bus.audio(s, 1);

	~patchCable1.scope;
	
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

	//You've got to order these correctly in the node tree, otherwise no sound

	~granGroup = Group.new();
	~ajmGranulator.wireUp(2, ~granGroup);
	~ajmGranulator.makeGranulators(~patchCable1.index, 20);
	~reverbGroup = Group.tail(s);
	~ajmSimpleReverb.makeSynth(~patchCable1.index, 1, ~reverbGroup);

});

)

~ajmGranulator.soundBuffer.plot();