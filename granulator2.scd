

(
//display the meter
s.meter;

//Set up the buffer to which sound is recorded
//It's 5 seconds and one channel
b = Buffer.alloc(s, s.sampleRate * 5, 1);

//Set up the audio buses for the mic and pointer
~micBus = Bus.audio(s, 1);
~ptrBus = Bus.audio(s, 1);

//This SynthDef reads the input signal, applies a volume and sends
//it to a bus
SynthDef.new(\micListener, {
	arg in = 0, out = 0, amp = 1;
	var sig;
	//Note: with SoundIn the first audio input is always 0
	sig = SoundIn.ar(in) * amp;
	Out.ar(out, sig);
}).add;

//This SynthDef generates the pointer that tells us where to
//write the input signal.
SynthDef.new(\pointer, {
	arg out = 0, buf = 0;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

//This SynthDef reads the mic signal and pointer signal and uses them
//to record sound into the buffer
SynthDef.new(\soundRecorder, {
	arg ptrIn = 0, micIn = 0, buf = 0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(micIn, 1);
	BufWr.ar(sig, buf, ptr);
}).add;

//This SynthDef is the granulator
SynthDef.new(\granulator, {
	arg
	amp = 0.5,
	buf = 0,
	out = 0,
	atk = 1,
	rel = 1,
	gate = 1,
	sync = 1,
	dens = 40,
	baseDur = 0.05,
	durRand = 1,
	rate = 1,
	rateRand = 1,
	pan = 0,
	panRand = 0,
	grainEnv = (-1),
	ptrBus = 0,
	ptrSampleDelay = 20000,
	ptrRandSamples = 5000,
	minPtrDelay = 1000;

	var sig, env, densCtrl, durCtrl, rateCtrl,
	panCtrl, ptr, ptrRand, totalDelay, maxGrainDur;

	//This envelope control the whole synth, not each grain
	//You can end the synth by setting gate = 0
	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);

	//TODO: Understand these 4 controls properly by reviewing both
	//Eli's granulation videos

	//The grain density control
	//If sync = 0, grains are sync'ed. Otherwise they're random
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	//The grain duration control, with some randomness
	durCtrl = baseDur * LFNoise1.ar(100).exprange(1 / durRand, durRand);
	//The rate control
	rateCtrl = rate * LFNoise1.ar(100).exprange(1 / rateRand, rateRand);
	//The pan control
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	//Implement a random delay in playback position
	ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
	totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	//Create a playback pointer
	ptr = In.ar(ptrBus, 1);
	ptr = ptr - totalDelay;
	ptr = ptr / BufFrames.kr(buf);

	//Calculate a maximum grain duration, to ensure we don't
	//bump into the recording point, where there's a discontinuity
	maxGrainDur = (totalDelay / rateCtrl) / SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		rateCtrl,
		ptr,
		2,
		panCtrl,
		grainEnv
	);

	//Scale the signal, add the envelope and output it
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

//Create groups to order the Synths
//Any synth that reads from a bus must be downstream
//from the synth that writes to that bus.
~micGrp = Group.new;
~ptrGrp = Group.after(~micGrp);
~recGrp = Group.after(~ptrGrp);
~grainGrp = Group.after(~recGrp);

)