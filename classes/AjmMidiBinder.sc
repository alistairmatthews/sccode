AjmMidiBinder {

	//This class binds footswitches and pedals on the FCB1010 to
	//values on the MVC model that you pass to the new method

	//The MVC model (an sc event)
	var <>model;

	*new {
		arg mod;
		//call the superclass new, then this class's init
		^super.new.init(mod);
	}

	init {
		arg mod;
		//Store the model
		model = mod;
		//Initiate midi control
		MIDIClient.init;
		MIDIIn.connectAll;
	}

	bindFootSwitch {
		arg footSwitchNumber, prop;

		postln("Binding footswitch" + footSwitchNumber + "to property" + prop);
		//Program messages are when I push a footswitch on the FCB1010
		MIDIdef.program(\programMessageReceiver, {
			arg val, chan, src;
			if(
				val == footSwitchNumber, //Pedal 1 sends a 0 etc
				{
					//the MIDI responder is in a different context to the main thread
					//so you can't call ~setValueFunction
					//We need to call ~setValueFunction separately from the MIDI responder
					//To do that, use defer.
					defer {
						if
						(
							//~revModel.onOff == 1,
							model[prop] == 1,
							{ ~setValueFunction.value(prop, 0) },
							{ ~setValueFunction.value(prop, 1) }
						);
					}
				}
			)
		});
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
					{ ~setValueFunction.value(pedalAProp, val.linlin(1, 127, 0, 1)) },
					{ ~setValueFunction.value(pedalBProp, val.linlin(1, 127, 0, 1)) }
				);
			}
		});
	}

}