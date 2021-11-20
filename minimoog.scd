
// Patch to demonstrate the minimoog synth

// Post things from inside the Synth
//o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

s.waitForBoot({ ~ajmMiniMoog = AjmMiniMoog.new(); });

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
//z.set("noisemix", 1, "noisetype", 0, "trig", 1, "filtercutofffreq", 2000);
//z.set("noisemix", 1, "noisetype", 0, "trig", 1, "filtercutofffreq", 100, "filterq", 0.1);
//z.set("noisemix", 1, "noisetype", 0, "trig", 1, "filtercutofffreq", 440, "filterq", 1);
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
	//	\filtercutofffreq, Pwhite(300, 2000),
	//\filtergain, 1,
	//\filtercontrol, Pseq([2, 0], inf)
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
	//\filtergain, 4,
	//\filterkeyboardcontrol, 1
).play;
)

// Troubleshooting code:
s.scope;
s.plotTree;

