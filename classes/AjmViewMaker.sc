AjmViewMaker {

	//This class creates groups of controls on the window passed into the new method
	//for the model passed in to the new method. You can also pass a highlight colour
	//to make things look themed.

	//The window where we'll create the controls
	var <>window;
	//The MVC model (an sc event)
	var <>model;
	//The calling class
	var <>caller;
	//The highlight colour
	var <>highlightColour;
	//The dictionary of control groups
	//Each group is all the controls for one property
	var <dicControlGroups;

	*new {
		//arg win, mod, colour;
		arg win, mod, call, colour;
		//call the superclass new, then this class's init
		//^super.new.init(win, mod, colour);
		^super.new.init(win, mod, call, colour);
	}

	init {
		//arg win, mod, colour;
		arg win, mod, call, colour;
		//Store the window and model
		window = win;
		model = mod;
		caller = call;
		highlightColour = colour;
		//Create a dictionary of controls groups
		dicControlGroups = Dictionary.new();
	}

	makeButton {
		arg prop, txtOn = "On", txtOff = "Off", left, top;
		var vwButton, arControls;

		//This is the array of controls to update when the value changes
		//In this case it's one button
		arControls = Array.new(maxSize: 0);

		//Create the button
		vwButton = Button.new(window, Rect(left, top, 40, 40))
		.states_([
			[txtOff, Color.black, Color.gray(0.4)],
			[txtOn, Color.black, highlightColour]
		])
		.value_(model[prop])
		.action_({
			arg view;
			postln("In makeButton. prop is " + prop + "value is " + view.value);
			caller.setValueFunction(prop, view.value);
			//~setValueFunction.value(prop, view.value);
		});

		//Add the button to the array
		arControls.add(vwButton);
		//Store the array in the control groups
		dicControlGroups.put(prop, arControls);
	}

	makeSliderGroup {
		arg prop, label, left = 20, top = 20, min = 0, max = 1, warp = \lin;
		var vwLabel, vwSlider, vwValueDisplay, vwNumberbox, arControls, ctlSpec;

		//Create the static text label for the slider
		vwLabel = StaticText.new(window, Rect(left, top, 100, 20))
		.string_(label);

		//Create the control spec to set min, max, and warp
		ctlSpec = ControlSpec.new(min, max, warp);

		//Create the slider
		vwSlider = Slider.new(window, Rect(left + 100, top, 180, 20))
		.background_(highlightColour)
		.value_(ctlSpec.unmap(model[prop]))
		.action_({
			arg view;
			postln("In makeSliderGroup. prop is " + prop + "value is " + view.value);
			caller.setValueFunction(prop, ctlSpec.map(view.value));
		});

		//Create the display box - it's a StaticText to stop the user from changing it
		vwValueDisplay = StaticText.new(window, Rect(left + 300, top, 44, 20))
		.string_(model[prop])
		.stringColor_(Color.white)
		.background_(Color.gray(0.2));

		//This is the array of controls we need when the value changes
		//A slider, a controlspec, and a value display static text
		arControls = Array.new(maxSize: 2);
		arControls.add(vwSlider);
		arControls.add(ctlSpec);
		arControls.add(vwValueDisplay);

		//Add the group of controls to the dictionary
		dicControlGroups.put(prop, arControls);

	}

	updateControls {
		arg prop, newValue;
		var controlGroup;
		//Get the right group of controls
		controlGroup = dicControlGroups.at(prop);
		//How to update the group depends on what the first control is
		if (
			controlGroup.at(0).isKindOf(Button),
			{
				//Set the button value
				postln("In updateControls. It's a button");
				controlGroup.at(0).value = newValue;
			},
			{
				//It must be a slider group
				postln("In updateControls. It's a slider");
				//Set the slider value using the controlspec
				controlGroup.at(0).value = controlGroup.at(1).unmap(newValue);
				//Set the display static text
				controlGroup.at(2).string = newValue.round(0.01);
			}
		);
	}

}