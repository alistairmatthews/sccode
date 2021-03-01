//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//TODO:
//1. If you want to reuse the granulator elsewhere, put the synths in a separate class.
//2. Work out how to distribute grains over 3 octaves.
//3. Build a control to change the time period that grains are distributed over

(

s.waitForBoot({

	~ajmGranulator = AjmGranulator.new();

	//Midi Control
	~ajmMidiBinder = AjmMidiBinder.new(~ajmGranulator);
	//Bind footswitch 1 to the In/Out property of the model
	~ajmMidiBinder.bindFootSwitch(0, \inOut);
	//Bind footswitch 2 to set the rate value to 0.5 (one octave down)
	~ajmMidiBinder.bindFootSwitch(1, \rate, 0.5);
	//Bind footswitch 3 to set the rate value to 1 (no pitch shift)
	~ajmMidiBinder.bindFootSwitch(2, \rate, 1);
	//Bind footswitch 4 to set the rate value to 2 (one octave up)
	~ajmMidiBinder.bindFootSwitch(3, \rate, 2);
	//Bind footswitch 5 to set the rate value to 4 (two octaves up)
	~ajmMidiBinder.bindFootSwitch(4, \rate, 4);
	//Bind footswitch 6 to set the rate randomization value to 0.01. A steady pitch
	~ajmMidiBinder.bindFootSwitch(5, \rateRand, 0.01);
	//Bind footswitch 7 to set the rate randomization value to 1.
	~ajmMidiBinder.bindFootSwitch(6, \rateRand, 1);
	//Bind footswitch 8 to set the rate randomization value to 50. Mayhem.
	~ajmMidiBinder.bindFootSwitch(7, \rateRand, 50);

	//TODO: should this wireUp call move into the class init?
	~ajmGranulator.wireUp(0);

	~ajmGranulator.makeGranulators(0, 20);

});

)

//Test In/Out
~ajmGranulator.setValueFunction(\inOut, 0);
~ajmGranulator.setValueFunction(\inOut, 1);
//Test rate
~ajmGranulator.setValueFunction(\rate, 0.5);
~ajmGranulator.setValueFunction(\rate, 1);
~ajmGranulator.setValueFunction(\rate, 2);
~ajmGranulator.setValueFunction(\rate, 4);
//Test random rate
~ajmGranulator.setValueFunction(\rateRand, 0.01);
~ajmGranulator.setValueFunction(\rateRand, 5);
~ajmGranulator.setValueFunction(\rateRand, 50);

//Stop the granulator by closing the gate
~ajmGranulator.granulators.do({ arg n; n.set(\gate, 0)});

//Testing the content of the buffer
~ajmGranulator.soundBuffer.plot;
~ajmGranulator.soundBuffer.play;
s.defaultGroup.deepFree;
