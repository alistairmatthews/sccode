//This is based on Eli Fieldsteels tutorial:
//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27

//Select the ASIO driver when you boot the server
//Otherwise the MME driver is selected and latency is too slow.

(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;
)

s.meter;

(
w = Window.new("Server Levels");
ServerMeterView.new(s, w, 0@0, 2, 2);
w.front;
)
//Create the buffer that will store audio for granulating
//5 seconds long and a single channel
b = Buffer.alloc(s, s.sampleRate * 5, 1);

//Create audio busses.
(
//This bus for the mic
~micBus = Bus.audio(s, 1);
//This bus for the record pointer
~ptrBus = Bus.audio(s, 1);
)

(
//This synthdef reads audio from a mic and sends it to a bus
//The only thing you can do is change the busses and apply a volume.
SynthDef.new(\micListener, {
	arg in = 0, out = 0, amp = 1;
	var sig;
	//Listen to the input and apply the amplitude
	sig = SoundIn.ar(in) * amp;
	Out.ar(out, sig);
}).add;

//This SynthDef generates the pointer that will be used
//to move the "record head" through the buffer as it writes
//audio there. This pointer loops through the buffer
//from the beginning to the end repeatedly.
SynthDef.new(\pointer, {
	arg out = 0, buf = 0;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

//This SynthDef gets the sound from the mic bus and writes it to the buffer at the position
//specified by the pointer
SynthDef.new(\soundRecorder, {
	arg ptrIn = 0, micIn = 0, buf = 0;
	var ptr, sig;
	//Get the pointer that represents the position of the record head
	ptr = In.ar(ptrIn, 1);
	//Get the sound from the mic buffer
	sig = In.ar(micIn, 1);
	//Write the mic sound to the buffer using the pointer
	BufWr.ar(sig, buf, ptr);
}).add;

//This SynthDef plays one grain at a time.
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

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl, ptr, ptrRand, totalPtrDelay, maxGrainDur;

	//Overall envelope, which can be held open with a gate
	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:Done.freeSelf);
	//The grain density control
	//If sync = 0, grains are sync'ed. Otherwise they're random
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	//The grain duration control, with some randomness
	durCtrl = baseDur * LFNoise1.ar(100).exprange(1/durRand, durRand);
	//The rate control
	rateCtrl = rate * LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	//The pan control
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	//Implement that randomness in the position of the play head
	ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
	totalPtrDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	//Get the pointer from the specified bus
	ptr = In.ar(ptrBus, 1);
	//Move the pointer back from the record head a little bit
	ptr = ptr - totalPtrDelay;
	//Scale the ptr value to be between zero and one
	ptr = ptr / BufFrames.kr(buf);

	//specify the length of the grain, making sure that it is less that the pointer dely.
	//This is to ensure that the discontinuity at the record head is not in the grain.
	maxGrainDur = (totalPtrDelay / rateCtrl) / SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	//Use GrainBuf to calculate the signal
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

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
//Create groups to order the synths correctly.
//Those that write to a bus have to be upstream from those that read from the same bus
~micGroup = Group.new;
~pointerGroup = Group.after(~micGroup);
~recGroup = Group.after(~pointerGroup);
~grainGroup = Group.after(~recGroup);

//Create the mic listener synth
Synth(\micListener, [\in, 0, \out, ~micBus], ~micGroup);
//Create the pointer synth
Synth(\pointer, [\buf, b, \out, ~ptrBus], ~pointerGroup);
//Create the sounde recorder synth
Synth(\soundRecorder, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, b], ~recGroup);
)

(
//This demo uses a single granulator
b.zero;
//Create the granulator synth
~g = Synth(\granulator, [
	\amp, 0.5,
	\buf, b,
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 1,
	\dens, 40,
	\baseDur, 0.05,
	\durRand, 1,
	\rate, 2,
	\rateRand, 0,
	\pan, 0,
	\panRand, 0.5,
	\grainEnv, -1,
	\ptrBus, ~ptrBus,
	\ptrSampleDelay, s.sampleRate/3,
	\ptrRandSamples, s.sampleRate/6,
	\minPtrDelay, 1000,
], ~grainGroup);
)
~g.set(\gate, 0);
b.plot;

(
//This demo uses an array of granulators to create a cloud of grains
b.zero;
~h = 20.collect({
	arg n;
	Synth(\granulator, [
		\amp, n.linlin(0, 49, -3, -20).dbamp, //This means the grains appear to fade out because the later playback granulators have a lower amplitude
		\buf, b,
		\out, 0,
		\atk, 1,
		\rel, 1,
		\gate, 1,
		\sync, 1,
		\dens, 40,
		\baseDur, 0.05,
		\durRand, 1,
		\rate, 2,
		\rateRand, 0,
		\pan, 0,
		\panRand, 0.5,
		\grainEnv, -1,
		\ptrBus, ~ptrBus,
		\ptrSampleDelay, n.linlin(0, 49, 20000, s.sampleRate * 4), //Distribute the playback heads across the last 2 seconds of recording
		\ptrRandSamples, 10000,
		\minPtrDelay, 1000,
	], ~grainGroup);
});
)
~h.do({ arg n; n.set(\gate, 0)});

