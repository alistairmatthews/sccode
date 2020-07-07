// A simple synth with two oscillators
SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1|
	var osc, env, output;
	// The oscillators play a saw wave on the left and a pulse wave on the right
	osc = [ Saw.ar(freq: freq, mul: amp), Pulse.ar(freq: freq + 3, width: 0.3, mul: amp)];
	// This is the envelope for each note.
	env = EnvGen.kr(Env.perc(0.01, sustain), doneAction: Done.freeSelf);
	// Apply the envelope
    output = osc * env;
	// Send it to the first two audio buses (left and right out)
    Out.ar(0, output);
}).add;

z = Synth(\singrain, [freq: 550]);  //Play a single note

// Play a set of notes by using a task
(
t = Task({
	loop {
        [600, 620, 640, 650, 670, 690, 710, 720].do({ |frequency|
			Synth(\singrain, [freq: frequency]);
            0.125.wait;
        });
	}
}).play;
)

t.play;
t.stop;