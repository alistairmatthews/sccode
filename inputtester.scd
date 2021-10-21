//This code tests what input bus sound is coming from

//Set up your sound card. We want to use the Focusrite ASIO driver
//If the Focusrite is not present, it SC uses the default soundcard
(
o = Server.default.options;
// This should only work on Windows
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;
)

//Display the meter
s.meter;

//Set up the buses
(
Buffer.freeAll;
~b0 = Buffer.alloc(s, s.sampleRate * 1, 1);
~b1 = Buffer.alloc(s, s.sampleRate * 1, 1);
~b2 = Buffer.alloc(s, s.sampleRate * 1, 1);
~b3 = Buffer.alloc(s, s.sampleRate * 1, 1);
)

//Record some sound into a buffer
(
SynthDef.new(\bufferRecorder,{
	arg out=0, in=0, bufnum=0;
    //Change this to take sound from the inputs
	var sig;
    sig = SoundIn.ar(in);    // get some noise
    RecordBuf.ar(sig, bufnum);     // by default this loops
}).add;
)

(
//Record into four bufs from four inputs
~rec0 = Synth(\bufferRecorder, [\in, 0, \bufnum, ~b0]); //Record from bus 0
~rec1 = Synth(\bufferRecorder, [\in, 1, \bufnum, ~b1]); //1
~rec2 = Synth(\bufferRecorder, [\in, 2, \bufnum, ~b2]); //2
~rec3 = Synth(\bufferRecorder, [\in, 3, \bufnum, ~b3]); //3
)
//release the recorders after a few seconds and display the plots
(
~rec0.free;
~rec1.free;
~rec2.free;
~rec3.free;
~b0.plot;
~b1.plot;
~b2.plot;
~b3.plot;
)

~b0.play;
~b1.play;
~b2.play;
~b3.play;
