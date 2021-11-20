AjmMiniMoog {

	//This is a monosynth like a minimoog without the filters

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
			gate = 1;

			var osc1, osc1freq, osc2, osc2freq, osc3, osc3freq, noise, volenv, outputsig;

			// This line is to send stuff to o for troubleshooting
			//SendTrig.kr(Impulse.kr(4), 0, osc1dutycycle);

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

			// Volume Envelope
			volenv = EnvGen.kr(Env.adsr(volenvattack, volenvdecay, volenvsustain, volenvrelease),  gate, doneAction: Done.freeSelf);

			// Mixer
			outputsig = ((osc1 * osc1mix) + (osc2 * osc2mix) + (osc3 * osc3mix) + (noise * noisemix)) * 0.6;

			// TODO: Fix this filter. Commented out for now
			// Filter
			// TODO: implement the "Amount of contour" control, which seems to fade the filter in and out
			// TODO: Filter frequency envelope?
			//outputsig = Select.ar( filtercontrol, [
			    //outputsig, // The filter is off when filter control = 0
			    //MoogFF.ar(outputsig, filtercutofffreq.lag(glisstime), filtergain, 0, (1/filtergain.sqrt)), //Take the filter cutoff from the argument when filter control = 1
			    //MoogFF.ar(outputsig, midinote.midicps.lag(glisstime), filtergain, 0, (1/filtergain.sqrt)) //Take the filter cutoff from the keyboard when filter control = 2
			//]);

			// Apply the volume envelope
			outputsig = outputsig * volenv;

			// Send the signal the synth output
			Out.ar(0, outputsig.dup);
		}).add;

	}
}
