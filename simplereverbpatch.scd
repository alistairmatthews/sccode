// TODO: Find out why the first input is bus 2.
// For the focusrite 2i4 there are 4 outputs (0 - 3) so the first input is 4 right?
// Does SC always create 2 outputs by default? That's not a bad thing of course.

(

s.waitForBoot({
	
	//Create the reverb
	~ajmSimpleReverb = AjmSimpleReverb.new();

	//MIDI Control
	~ajmMidiBinder = AjmMidiBinder.new(~ajmSimpleReverb);
	//Bind footswitch 1 to the On/Off property of the model
	~ajmMidiBinder.bindFootSwitch(0, \onOff);
	//Bind expression pedal A to the Mix property of the model
	//and pedal B to the Room property
	~ajmMidiBinder.bindExpressionPedals(\mix, \room);

	//Create the synth. Read from the left and play to the right.
	~ajmSimpleReverb.makeSynth(0, 1);

});

)

//Test changes
//~ajmSimpleReverb.setValueFunction(\onOff, 1);
//~ajmSimpleReverb.setValueFunction(\onOff, 0);
//~ajmSimpleReverb.setValueFunction(\onOff, 1);
//~ajmSimpleReverb.setValueFunction(\mix, 0.5);
//~ajmSimpleReverb.setValueFunction(\room, 0.25);
//~ajmSimpleReverb.setValueFunction(\damp, 0.25);
