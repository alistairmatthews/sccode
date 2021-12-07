//Kick drums

(
SynthDef(\electroKickDrum, {

	//This is a simple sine wave, with an envelope
	
    var osc, env, output;

    osc = {SinOsc.ar(60)};
    env = {Line.ar(1, 0, 1, doneAction: 2)};

    output = osc * env;

    Out.ar(0,
        Pan2.ar(output, 0)
    )

}).add;
)

t = Synth(\electroKickDrum);

(
SynthDef(\clickKickDrum, {

	//This one is the same but with a white noise click at the start
		
    var subosc, subenv, suboutput, clickosc, clickenv, clickoutput;
		
    subosc = {SinOsc.ar(60)};
    subenv = {Line.ar(1, 0, 1, doneAction: 2)};

    clickosc = {LPF.ar(WhiteNoise.ar(1),1500)};
    clickenv = {Line.ar(1, 0, 0.03)};

    suboutput = (subosc * subenv);
    clickoutput = (clickosc * clickenv);

    Out.ar(0,
        Pan2.ar(suboutput + clickoutput, 0)
    )

}).add;
)

t = Synth(\clickKickDrum);

//High-hats

(
SynthDef(\electroOpenHat, {

	//This open high hat uses filtered and enveloped white noise
	
    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.3, doneAction: 2)};

    hatoutput = (hatosc * hatenv);

    Out.ar(0, Pan2.ar(hatoutput, 0));

}).add;
)

(
SynthDef(\electroClosedHat, {

	//Same as the open high hat but with a shorter envelope
	
    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.1, doneAction: 2)};

    hatoutput = (hatosc * hatenv);

    Out.ar(0, Pan2.ar(hatoutput, 0));

}).add;
)

o = Synth(\electroOpenHat);
c = Synth(\electroClosedHat);

(
SynthDef(\electroSnareDrumOff, {

	//This one uses a square wave, filtered.
	//The filter frequency is enveloped.
	//Think of this as the snare drum with the snare off
	
	var drumosc, filterenv, drumoutput, volenv;

	filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
	volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};

	drumosc = {Pulse.ar(75)};
	drumoutput = {LPF.ar(drumosc,(filterenv * 1000) + 30)};

	Out.ar(0, Pan2.ar(drumoutput * volenv, 0));

}).add;
)

t = Synth(\electroSnareDrumOff);

(
SynthDef(\electroSnareDrum, {

	//Same as the previous one but with some white noise at the start
	//to simulate the snare.
	
	var drumosc, filterenv, volenv, drumoutput, snaposc, snapenv, fulloutput;

	drumosc = {Pulse.ar(75)};
	filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
	volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};
	drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

	snaposc = {BPF.ar(HPF.ar(WhiteNoise.ar(1),500),1500)};
	snapenv = {Line.ar(1, 0, 0.2, doneAction: 0)};

	fulloutput = (drumoutput * volenv) + (snaposc * snapenv);
	//fulloutput = (drumoutput * volenv);

	Out.ar(0, Pan2.ar(fulloutput, 0))

}).add;
)

t = Synth(\electroSnareDrum);

//Example beat

(
p = Pbind(
	\instrument, \electroClosedHat,
	\dur, 1/4
).play(TempoClock.default, quant: 1.0);
)

(
q = Pbind(
	\instrument, \electroSnareDrum,
	\dur, 8
).play(TempoClock.default, quant: 4.0);
)

p.stop;
q.stop;