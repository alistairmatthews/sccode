AjmViewMaker {

	//TODO: Implement custom colours as arguments

	//The window where we'll create the controls
	var <>window;
	//The MVC model (an sc event)
	var <>model;
	//The dictionary of control groups
	//Each group is all the controls for one property
	var dicControlGroups;

	*new {
		arg win, mod;
		//call the superclass new, then this class's init
		^super.new.init(win, mod);
	}

	init {
		arg win, mod;
		//Store the window and model
		window = win;
		model = mod;
		//Create a dictionary of controls groups
		dicControlGroups = Dictionary.new();
	}

	makeButton {
		arg prop, txtOn = "On", txtOff = "Off", left, top;
		var vwButton, arControls;

		arControls = Array.new(maxSize: 1);

		//Create the button
		vwButton = Button.new(window, Rect(left, top, 40, 40))
		.states_([[txtOn], [txtOff]])
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
		var vwLabel, vwSlider, vwNumberbox, arControls;

		arControls = Array.new(maxSize: 2);

		//Create the static text label for the slider
		vwLabel = StaticText.new(window, Rect(left, top, 100, 20)).string_(label);

		//Create the slider
		vwSlider = Slider.new(window, Rect(left + 100, top, 180, 20))
		.value_(model[prop])
		.action_({
			arg view;
			~setValueFunction.value(prop, view.value);
		});
		arControls.add(vwSlider);

		//Create the number box
		vwNumberbox = NumberBox.new(window, Rect(left + 300, top, 44, 20))
		.value_(model[prop]);
		//To do - how to make this box read only?
		arControls.add(vwNumberbox);

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
			control.value_(newValue);
		});
	}

}