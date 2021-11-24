s.waitForBoot();
s.quit();


(

s.waitForBoot({

	//Create the input stage
	~ajmInputStage = AjmInputStage.new();

	//TODO: this seems to run too quickly when the synth def is not ready.
	//Create the synth
	~ajmInputStage.makeSynth(0, 1, 0);
});

)

s.plotTree();
