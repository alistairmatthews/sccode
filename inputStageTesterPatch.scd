s.waitForBoot();
s.quit();


(

s.waitForBoot({

	//Create the input stage
	~ajmInputStage = AjmInputStage.new();

	//Create the synth
	~ajmInputStage.makeSynth(0, 1, 0);
});

)

s.plotTree();