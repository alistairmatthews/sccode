AjmAdditivePolySynth {

	//This is a polyphonic synth that adds triangular waves

	*new {
		//Call the superclass new, then this class's init
		^super.new.init();
	}

	init {
		//Make the synth def
		this.makeSynthDef();
	}

	makeSynthDef {

		//Make the synth def and send it to the server

		SynthDef(\addPolySynth, {
			arg freq = 440, attack = 0.1, release = 1, vol = 1, out;
			var sig, env;

			sig = LFTri.ar(freq) + (LFTri.ar(freq * 2) * 0.5) + (LFTri.ar(freq * 4) * 0.25);
			sig = sig * 0.3;
			env = EnvGen.kr(Env.perc(attack, release), doneAction: Done.freeSelf);
			sig = sig * env * vol;
			Out.ar(out, sig.dup);
		}).add;
		
	}
	
}