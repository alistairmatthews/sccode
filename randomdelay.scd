
// Set up the buffer for the recorded sound
b = Buffer.alloc(s, s.sampleRate * 10.0, 1); // a 10 second mono buffer
b.free;

(

// This SynthDef records incoming audio to the buffer
SynthDef("RandomDelayInput", {
	arg outBus = 0, inBus, bufnum;
	var input;

	//Get the input from the specified bus, mono
	input = In.ar(inBus, 1);

	//Record it to the buffer
	RecordBuf.ar(input, bufnum);

	//Not playing anything here
}).add;
)

(
// This SynthDef plays audio from the buffer
SynthDef("RandomDelayOutput", {
	arg outBus = 0, bufnum;
	var output;

	// Play the audio from the buffer

	// TODO: This currently plays the buffer straight
	// The delay depends on when you start this synth.
	// How to play a random selection from the buffer?
	output = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1.0);

	Out.ar(outBus, output);
}).add;
)

b.plot;

x = Synth.new("RandomDelayInput", [\inBus, 2, \bufnum, b]);
y = Synth.new("RandomDelayOutput", [\outBus, 0, \bufnum, b]);

x.free;
y.free;