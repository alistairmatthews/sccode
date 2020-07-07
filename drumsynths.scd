(
SynthDef('kickdrum', {

    var osc, env, output;

    osc = {SinOsc.ar(60)};
    env = {Line.ar(1, 0, 1, doneAction: 2)};

    output = osc * env;

    Out.ar(0,
        Pan2.ar(output, 0)
    )

}).send(s);
)

t = Synth('kickdrum');

(
    SynthDef('fullkickdrum', {

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

}).send(s);
)

t = Synth('fullkickdrum');

(
SynthDef('openhat', {

    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.3)};

    hatoutput = (hatosc * hatenv);

    Out.ar(0,
    Pan2.ar(hatoutput, 0)
)

}).send(s);

SynthDef('closedhat', {

    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.1)};

    hatoutput = (hatosc * hatenv);

    Out.ar(0,
    Pan2.ar(hatoutput, 0)
    )

}).send(s);
)

o = Synth('openhat');
c = Synth('closedhat');

(
SynthDef('snaredrum', {

var drumosc, filterenv, drumoutput, volenv;

filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};

drumosc = {Pulse.ar(75)};
drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

Out.ar(0,
Pan2.ar(drumoutput * volenv, 0)
)

}).send(s);
)

t = Synth('snaredrum');

(
SynthDef('snaredrum2', {

var drumosc, filterenv, volenv, drumoutput, snaposc, snapenv, fulloutput;

drumosc = {Pulse.ar(75)};
filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};
drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

snaposc = {BPF.ar(HPF.ar(WhiteNoise.ar(1),500),1500)};
snapenv = {Line.ar(1, 0, 0.2, doneAction: 0)};

fulloutput = (drumoutput * volenv) + (snaposc * snapenv);
//fulloutput = (drumoutput * volenv);

Out.ar(0,
Pan2.ar(fulloutput, 0)
)

}).send(s);
)

t = Synth('snaredrum2');

(
p = Pbind(
	\instrument, \fullkickdrum,
).play;
)

p.stop;