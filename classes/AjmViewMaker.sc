AjmViewMaker {

	//This class creates groups of controls on the window passed into the new method
	//for the model passed in to the new method. You can also pass a highlight colour
	//to make things look themed.

	//The window where we'll create the controls
	var <>window;
	//The MVC model (an sc event)
	var <>model;
	//The highlight colour
	var <>highlightColour;
	//The dictionary of control groups
	//Each group is all the controls for one property
	var dicControlGroups;

	*new {
		arg win, mod, colour;
		//call the superclass new, then this class's init
		^super.new.init(win, mod, colour);
	}

	init {
		arg win, mod, colour;
		//Store the window and model
		window = win;
		model = mod;
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
			~setValueFunction.value(prop, view.value);
		});

		//Add the button to the array
		arControls.add(vwButton);
		//Store the array in the control groups
		dicControlGroups.put(prop, arControls);
	}

	makeSliderGroup {
		arg prop, label, left, top;
		var vwLabel, vwSlider, vwValueDisplay, vwNumberbox, arControls;

		//This is the array of controls to update when the value changes
		//A slider and a statictext
		arControls = Array.new(maxSize: 1);

		//Create the static text label for the slider
		vwLabel = StaticText.new(window, Rect(left, top, 100, 20))
		.string_(label);

		//Create the slider
		vwSlider = Slider.new(window, Rect(left + 100, top, 180, 20))
		.background_(highlightColour)
		.value_(model[prop])
		.action_({
			arg view;
			~setValueFunction.value(prop, view.value);
		});
		arControls.add(vwSlider);

		//Create the display box - it's a StaticText to stop the user from changing it
		vwValueDisplay = StaticText.new(window, Rect(left + 300, top, 44, 20))
		.string_(model[prop])
		.stringColor_(Color.white)
		.background_(Color.gray(0.2));
		arControls.add(vwValueDisplay);

		//Add the group of controls to the dictionary
		dicControlGroups.put(prop, arControls);

	}

	updateControls {
		arg prop, newValue;
		var controlGroup;
		//Get the right group of controls
		controlGroup = dicControlGroups.at(prop);
		//Update all the controls in the group
		controlGroup.do({
			arg control;
			if (
				control.isKindOf(StaticText),
				{ control.string = newValue.round(0.01) },
				{ control.value = newValue }
			)
		});
	}

}