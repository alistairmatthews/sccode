s.waitForBoot();
s.quit();

//TODO display level meters?

(

s.waitForBoot({

	//Create the input stage
	~ajmInputStage = AjmInputStage.new();

	//TODO: sometimes this seems to run too quickly when the synth def is not ready.
	//Create the synth
	~ajmInputStage.makeSynth(1);
});

)

s.plotTree();
