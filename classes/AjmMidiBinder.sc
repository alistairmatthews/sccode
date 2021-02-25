AjmMidiBinder {

	//This class binds footswitches and pedals on the FCB1010 to
	//values on the MVC model in the class that you pass to the new method

	//The object that we want to bind pedals to
	var <>stompbox;

	*new {
		arg stomp;
		//call the superclass new, then this class's init
		^super.new.init(stomp);
	}

	init {
		arg stomp;
		//Store the model
		stompbox = stomp;
		//Initiate midi control
		MIDIClient.init;
		MIDIIn.connectAll;
	}

	bindFootSwitch {
		arg footSwitchNumber, prop, bindVal = -1;

		if (
			bindVal == -1,
			{
				//We're binding a footswitch to toggle a value between 0 and 1
				postln("Binding footswitch" + footSwitchNumber
					+ "to toggle property" + prop);

				//Add the Midi responder to the list
				MIDIdef.program(\footswitch ++ footSwitchNumber, {
					arg val, chan, src;
					//the MIDI responder is in a different context to the main thread
					//so you can't call stompbox.setValueFunction
					//We need to call stompbox.setValueFunction separately from the
					//MIDI responder. To do that, use defer.
					defer {
						postln("Toggling" + prop);
						if
						(
							stompbox.model[prop] == 1,
							{ stompbox.setValueFunction(prop, 0) },
							{ stompbox.setValueFunction(prop, 1) }
						);
					}
				}, 5, nil, footSwitchNumber);
			},
			{
				//We're binding a footdswitch to set a property to a fixed value
				postln("Binding footswitch" + footSwitchNumber +
					"to set property" + prop + "to value" + bindVal);

				//Add the MIDIdef
				MIDIdef.program(\footswitch ++ footSwitchNumber, {
					arg val, chan, src;
					//the MIDI responder is in a different context to the main thread
					//so you can't call stompbox.setValueFunction
					//We need to call stompbox.setValueFunction separately from the
					//MIDI responder. To do that, use defer.
					defer {
						postln("Setting" + prop + "to" + bindVal);
						stompbox.setValueFunction(prop, bindVal);
					}
				}, 5, nil, footSwitchNumber);
			}
		);
	}

	bindExpressionPedals {
		arg pedalAProp, pedalBProp;

		postln("Binding pedal A to property" + pedalAProp);
		postln("Binding pedal B to property" + pedalBProp);
		//Control change messages are when I alter an expression pedal on the FCB1010
		MIDIdef.cc(\ccMessageReceiver, {
			arg val, num, chan, src;
			defer {
				if(
					chan == 1,
					{ stompbox.setValueFunction(pedalAProp, val.linlin(1, 127, 0, 1)) },
					{ stompbox.setValueFunction(pedalBProp, val.linlin(1, 127, 0, 1)) }
				);
			}
		});
	}

}