AjmGranulator {

	makeSynthDefs {
		//This SynthDef reads the input signal, applies a volume and sends
		//it to a bus
		SynthDef.new(\micListener, {
			arg in = 0, out = 0, amp = 1;
			var sig;
			//Note: with SoundIn the first audio input is always 0
			sig = SoundIn.ar(in) * amp;
			Out.ar(out, sig);
		}).add;

		//This SynthDef generates the pointer that tells us where to
		//write the input signal.
		SynthDef.new(\pointer, {
			arg out = 0, buf = 0;
			var sig;
			sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
			Out.ar(out, sig);
		}).add;

		//This SynthDef reads the mic signal and pointer signal and uses them
		//to record sound into the buffer
		SynthDef.new(\soundRecorder, {
			arg ptrIn = 0, micIn = 0, buf = 0;
			var ptr, sig;
			ptr = In.ar(ptrIn, 1);
			sig = In.ar(micIn, 1);
			BufWr.ar(sig, buf, ptr);
		}).add;


	}


	makeSynths {
		arg server, buffer;
		//Set up the audio buses for the mic and pointer
		~micBus = Bus.audio(server, 1);
		~ptrBus = Bus.audio(server, 1);

		//Create groups to order the Synths
		//Any synth that reads from a bus must be downstream
		//from the synth that writes to that bus.
		~micGrp = Group.new;
		~ptrGrp = Group.after(~micGrp);
		~recGrp = Group.after(~ptrGrp);
		~grainGrp = Group.after(~recGrp);

		//Now we can set up the synths, placing each into the right group
		Synth(\micListener, [\in, 0, \out, ~micBus], ~micGrp);
		Synth(\pointer, [\buf, buffer, \out, ~ptrBus], ~ptrGrp);
		Synth(\soundRecorder, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, buffer], ~recGrp);
		//Note that we leave the granulator synth to the caller
	}

}