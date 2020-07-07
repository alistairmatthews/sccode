// Troubleshooting code:

// Show the tree of nodes
s.plotTree;

// Show the scope
s.scope;

// Post things from inside the Synth
o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

// ajm's Mini Moog
(
SynthDef.new(\ajmMiniMoog, {
	arg midinote = 69,
	   glisstime = 0,
	   osc1wave = 0,
	   osc1mix = 1,
	   osc1dutycycle = 0.5,
	   osc2wave = 1,
	   osc2octave = 0,
	   osc2detune = 0,
	   osc2dutycycle = 0.5,
	   osc2mix = 0,
	   osc3wave = 1,
	   osc3octave = 0,
	   osc3detune = 0,
	   osc3dutycycle = 0.5,
	   osc3mix = 0,
	   noisetype = 0,
	   noisemix = 0,
	   volenvattack = 0.1,
	   volenvdecay = 1,
	   volenvsustain = 0.5,
	   volenvrelease = 1,
	   filtercutofffreq = 440,
	   filtergain = 0.1, // can be between 0 and 4
	   filtercontrol = 0, // 0 = filter off, 1 = filter freq from arg, 2 = filter freq from keyboard
	   gate = 1;
	var osc1, osc1freq, osc2, osc2freq, osc3, osc3freq, noise, volenv, outputsig;
	// This line is to send stuff to o for troubleshooting
	SendTrig.kr(Impulse.kr(4), 0, osc1dutycycle);
	// Store the frequencies for the oscilators. Use lag to implement glissando
	osc1freq = midinote.midicps.lag(glisstime);
	osc2freq = ((midinote + (12 * osc2octave)).midicps + osc2detune).lag(glisstime);
	osc3freq = ((midinote + (12 * osc3octave)).midicps + osc3detune).lag(glisstime);
	// First oscillator
	osc1 = Select.ar(osc1wave, [
		VarSaw.ar(osc1freq, 0, osc1dutycycle), // saw when osc1wave = 0
		Pulse.ar(osc1freq, osc1dutycycle) // square when osc1wave = 1
	]);
	// Second oscillator
	osc2 = Select.ar(osc2wave, [
		VarSaw.ar(osc2freq, 0, osc2dutycycle), // saw when osc2wave = 0
		Pulse.ar(osc2freq, osc2dutycycle) //square when osc2wave = 1
	]);
	// Third oscillator
	osc3 = Select.ar(osc3wave, [
		VarSaw.ar(osc3freq, 0, osc3dutycycle), // saw when osc3wave = 0
		Pulse.ar(osc3freq, osc3dutycycle) //square when osc3wave = 1
	]);
	// Noise
	noise = Select.ar(noisetype, [
		WhiteNoise.ar, // White noise when noisetype = 0
		PinkNoise.ar // Pink noise when noisetype = 1
	]);
	volenv = EnvGen.kr(Env.adsr(volenvattack, volenvdecay, volenvsustain, volenvrelease),  gate, doneAction: Done.freeSelf);
	// Mixer
	outputsig = ((osc1 * osc1mix) + (osc2 * osc2mix) + (osc3 * osc3mix) + (noise * noisemix)) * 0.6;
	// Filter
	// TODO: implement the "Amount of contour" control, which seems to fade the filter in and out
	// TODO: Filter frequency envelope?
	outputsig = Select.ar( filtercontrol, [
		outputsig, // The filter is off when filter control = 0
		MoogFF.ar(outputsig, filtercutofffreq.lag(glisstime), filtergain, 0, (1/filtergain.sqrt)), //Take the filter cutoff from the argument when filter control = 1
		MoogFF.ar(outputsig, midinote.midicps.lag(glisstime), filtergain, 0, (1/filtergain.sqrt)) //Take the filter cutoff from the keyboard when filter control = 2
	]);
	// Volume envelope
	outputsig = outputsig * volenv;
	Out.ar(0, outputsig.dup);
}).add;
)

// Test various notes and waveforms
x = Synth.new(\ajmMiniMoog, ["gate", 1]);
x.set("osc1wave", 1, "gate", 1);
x.set("osc1dutycycle", 0.1);
x.set("osc1dutycycle", 0.9);
x.set("osc1wave", 1);
x.set("osc1wave", 0);
x.set("midinote", 30);
x.set("gate", 0);
x.free;

y = Synth.new(\ajmMiniMoog, ["midinote", 25, "osc1wave", 1, "trig", 1]); // 69 = A4
y.set("gate", 0);
y.set("gate", 1);
y.set("midinote", 90, "gate", 1);
y.set("midinote", 90, "glisstime", 5.0, "gate", 1);
y.set("midinote", 35, "osc1wave", 1, "osc2wave", 2, "osc2octave", 0, "gate", 1);
y.set("midinote", 35, "osc1wave", 1, "osc2wave", 2, "osc2octave", -1, "gate", 1);
y.set("midinote", 35, "osc1wave", 1, "osc2wave", 2, "osc2octave", 2, "gate", 1);
y.set("midinote", 35, "osc1wave", 1, "osc2wave", 2, "osc2octave", 2, "osc2detune", 0.5, "gate", 1);
y.set("midinote", 35, "osc1wave", 0, "osc2wave", 1, "osc2octave", 1, "osc3wave", 2, "osc3octave", 2, "gate", 1);
y.free;

z = Synth.new(\ajmMiniMoog, ["midinote", 75, "osc1wave", 0, "trig", 1]); // 75 = D#5
z.set("gate", 0);
z.free;

z = Synth.new(\ajmMiniMoog, ["midinote", 69, "osc2wave", 2, "trig", 1]); // 100 = E7
z.set("trig", 0);
z.set("noisemix", 1, "noisetype", 0, "trig", 1);
z.set("noisemix", 1, "noisetype", 1, "trig", 1);
z.set("noisemix", 1, "noisetype", 0, "trig", 1, "filtercutofffreq", 2000);
z.set("noisemix", 1, "noisetype", 0, "trig", 1, "filtercutofffreq", 100, "filterq", 0.1);
z.set("noisemix", 1, "noisetype", 0, "trig", 1, "filtercutofffreq", 440, "filterq", 1);
z.free;

// Use this block to play different notes on y once it's already running
(
// Note and waveform sequences
var noteseq = Pseq([69, 35, 75, 71], 2).asStream;
var osc1waveseq = Pseq([0, 1, 0, 2], 2).asStream;
var osc2waveseq = Pseq([2, 1, 1, 0], 2).asStream;

// Set the tempo
TempoClock.default.tempo = 2;

// Create a synth
a = Synth.new(\ajmMiniMoog, ["midinote", 69, "osc1wave", 1, "osc2wave", 0, "env1attack", 2]);

// Use a task to schedule notes
r = Task({
	var note, osc1waveform, osc2waveform;
	// Loop through the pattern
	while {
		note = noteseq.next;
		note.notNil
	} {
		// Remember to move to the next waveforms as well
		osc1waveform = osc1waveseq.next;
		osc2waveform = osc2waveseq.next;
		// Show what's going on
		"Note: ".post;
		note.post;
		", Osc1 Wave: ".post();
		osc1waveform.post();
		", Osc2 Wave: ".post();
		osc2waveform.postln();
		// Change what the synth is playing and re-trigger
		a.set("midinote", note, "osc1wave", osc1waveform, "osc2wave", osc2waveform, "trig", 1);
		// Yield for 1 beat.
		1.yield;
		a.set("trig", 0);
		1.yield;
	}
}).play;

)

r.stop;

// Use PmonoArtic to play the Synth, randomising a load of arguments.
// PmonoArtic is like Pmono, but you can specify a sustain argument.
// In Pmono, the result is a single output, varying arguments such as pitch,
// but the envelope is not triggered each time, so you get varying notes at
// the sustain level.
// In PmonoArtic, if the sustain is longer that dur, the behaviour is the same as
// Pmono - the envelope is not re-triggered. If sustain is shorter than dur,
// the release is sounded, but note that the next note will create a new synth
// to play. To prevent infinite synths, you must add a doneAction: Done.freeSelf
// to the SynthDef's envelope.
(
p = PmonoArtic(
	\ajmMiniMoog,
	\dur, 0.4,
	\sustain, Pwhite(0.1, 2),
	\midinote, Pseq([67, 54, 23, 100, 89, 23], inf),
	//\midinote, Pseq([35, 30, 24, 35, 89, 23], inf),
	\glisstime, 0.1,
	\osc1wave, Pwhite(0, 3),
	\osc1dutycycle, Pwhite(0.1, 0.9),
	\osc2wave, Pwhite(0, 2),
	\osc2octave, Pwhite(-2, 3),
	\osc2detune, Pwhite(-2.0, 2.0),
	\osc2dutycycle, Pwhite(0.1, 0.9),
	\osc3wave, Pwhite(0, 2),
	\osc3octave, Pwhite(-2, 3),
	\osc3detune, Pwhite(-2.0, 2.0),
	\osc3dutycycle, Pwhite(0.1, 0.9),
	\noisetype, Pseq([0, 1], inf),
	\noisemix, Pwhite(0.0, 1.0),
	\volenvattack, Pwhite(0.01, 0.5),
	\volenvdecay, Pwhite(0.01, 1.0),
	\volenvsustain, Pwhite(0.1, 1.0),
	\volenvrelease, Pwhite(0.01, 1.0),
	\filtercutofffreq, Pwhite(300, 2000),
	\filtergain, 1,
	\filtercontrol, Pseq([2, 0], inf)
).play;
)

TempoClock.default.tempo = 2;
TempoClock.default.tempo = 1;

p.stop;

(
p = PmonoArtic(
	\ajmMiniMoog,
	\dur, 0.4,
	\sustain, 0.4,
	\midinote, Pseq([67, 54, 23, 100, 89, 23], inf),
	\glisstime, 0,
	\osc1wave, Pwhite(0, 1),
	\osc1dutycycle, Pwhite(0.0, 1.0),
	\osc2mix, 0,
	\osc3mix, 0
).play;
)

p.stop;

(
p = PmonoArtic(
	\ajmMiniMoog,
	\dur, 0.2,
	\sustain, Pwhite(0.1, 1.0),
	\midinote, Pseq([67, 54, 23, 100, 89, 23], inf),
	\osc1wave, Pwhite(0, 3),
	\osc2mix, Pwhite(0.3, 1.0),
	\osc2wave, Pwhite(0, 2),
	\osc2octave, 2,
	\osc2detune, Pwhite(-2.0, 2.0),
	\osc3mix, Pwhite(0.3, 1.0),
	\osc3wave, Pwhite(0, 2),
	\osc3detune, Pwhite(-2.0, 2.0)
).play;
)

p.stop;

(
p = PmonoArtic(
	\ajmMiniMoog,
	\dur, 0.2,
	\sustain, Pwhite(0.1, 1.0),
	\midinote, Pseq([67, 54, 23, 100, 89, 23], inf),
	\glisstime, 0.1,
	\osc1mix, 0,
	\osc2mix, 0,
	\osc3mix, 0,
	\noisetype, 0,
	\noisemix, 1,
	\filtergain, 4,
	\filterkeyboardcontrol, 1
).play;
)

s.scope;
s.plotTree;

