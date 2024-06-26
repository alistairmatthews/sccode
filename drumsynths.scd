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

(
SynthDef(\betterKick, {
	arg freqA = 1000, freqB = 50, freqC = 10, freqDur1 = 0.01, freqDur2 = 0.2, freqCurv1 = 1, freqCurv2 = (-1),
	    atk = 0.01, rel = 1, curv1 = 1, curv2 = (-12), amp = 0.8, out = 0;
	var sig, env, freqSweep;

	//Set up how the frequency changes
	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqCurv1, freqCurv2]).ar;
	//Set up the signal envelope. The .kr(2) bit makes sure the synth is freed when the env is complete
	env = Env([0, 1, 0], [atk, rel], [curv1, curv2]).kr(2);
	//Create the signal
	sig = SinOsc.ar(freqSweep, pi/2);
	//Apply the envelope
	sig = sig * env * amp;
	Out.ar(out, sig.dup());
}).add;	
)

//Default freq envelope looks like this:
Env([1000, 50, 10], [0.01, 0.2], [1, -1]).plot;
//Default signal envelope looks like this:
Env([0, 1, 0], [0.01, 1], [1, -12]).plot;

t = Synth(\betterKick);
t = Synth(\betterKick, [\freqA, 500, \amp, 1]);


//High-hats

(
SynthDef(\electroOpenHat, {

	//This open high hat uses filtered and enveloped white noise
	arg amp = 0.5;
    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.3, doneAction: 2)};

    hatoutput = (hatosc * hatenv * amp);

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

(
SynthDef("hihat", {
	arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;
)

n = Synth(\hihat);
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

(
SynthDef(\betterSnare, {
	arg out = 0, amp = 0.1, sinfreq = 150, att = 0.01, rel = 0.2, ffreq = 800, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;
)

h = Synth(\betterSnare);
t = Synth(\betterSnare, [\sinfreq, 150, \ffreq, 800, \amp, 1, \rel, 0.5]);

(
SynthDef(\zaps, {
	arg amp = 1, modFreq = 15, carFreq = 880, modDepth = 3250;
	var car, mod, env;

	env = Env.perc(releaseTime: 0.3).kr(doneAction: 2);
	mod = Pulse.ar(freq: modFreq * [1, 1.14, 0.97, 6, 7, 8, 9, 10, 1.04, 1.2], mul: modDepth);
	car = Pulse.ar(freq: carFreq + mod * [1, 1.41, 0.99, 2.4921, 5, 6, 1.397], mul: env);
	car = Splay.ar(car);

	Out.ar(0, FreeVerb.ar(HPF.ar(car, freq: 5274), mix: 0.05, room: 0.1, damp: 0.9, mul: amp * 0.5));
	
}).add;
)

i = Synth(\zaps);
i = Synth(\zaps, [\modfreq, 10, \carfreq, 800, \amp, 1, \modDepth, 3250]);

(
SynthDef.new(\ding, {
    arg freq = #[1600,200,177,384,730,1255,60], rel=0.5, noiseRel=0.05, noiseLevel=0.7;

    var osc = Mix.arFill(7, { arg i;
        SinOsc.ar(freq[i])*0.3;
    });
    var e = EnvGen.ar(Env.perc(0.01, rel), doneAction: 2);

    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;

    var snd =  noiseOsc * noiseEnv + osc*e;

    Out.ar(0,Pan2.ar(snd))

}).add;
)

x = Synth.new(\ding);
x = Synth.new("ding", ["freq",Array.fill(7,{rrand(2000,60)}), "rel", rrand(1,0.05), "noiseRel",rrand(0.1,0), "noiseLevel", rrand(0,0.4)]);

//Example beat

(
p = Pbind(
	\instrument, \hihat,
	\dur, Prand([1/2, 1/4, 1/4, 1/8, 1/8, 1/4, 1/4, 1/4], inf),
	\amp, Pseq([0.5, 0.3, 0.2, 0.2, 0.1, 0.2, 0.2, 0.05], inf),
	\ffreq, Prand([6000, 5000, 4000, 3000, 2000, 1000], inf),
	\rel, Prand([0.2, 1.0], inf)
).play(TempoClock.default, quant: 1.0);
)

(
q = Pbind(
	\instrument, \betterKick,
	\dur, 1,
	\amp, Prand([1, 0.7, 0.2, 0.4], inf),
	\freqA, Pseq([1000, 500, 700, 2000], inf)
).play(TempoClock.default, quant: 1.0);
)

(
r = Pbind(
	\instrument, \zaps,
	\dur, Prand([1, 3, 1, 3], inf),
	\amp, Prand([1, 0.7, 0.6, 0.4], inf),
).play(TempoClock.default, quant: 3.0);
)

(
t = Pbind(
	\instrument, \ding,
	\dur,  Pseq([1/2, 1/4, 1/4, 1/8, 1/8, 1/4, 1/4, 1/4], inf),
	\amp, Prand([1, 0.5, 0.6, 0.8, 0.2], inf),
	\freq, Prand(Array.fill(7,{rrand(2000,60)}), inf),
	\rel, Prand([1, 0.3, 0.1, 0.7], inf)
).play(TempoClock.default, quant: 3.0);
)

p.play(quant: 1.0);
p.stop;
q.play(quant: 1.0);
q.stop;
r.stop;
t.stop;