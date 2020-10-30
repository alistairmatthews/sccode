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
			~setValueFunction.value(model[prop], view.value);
		}); //This works fine but the MVC controller doesn't set this slider or the number box
		arControls.add(vwSlider);

		//To fix this store all views in an array or something here
		//Then create a method to update those views
		//then call that method from the MVC controller

		//Create the number box
		vwNumberbox = NumberBox.new(window, Rect(left + 300, top, 44, 20))
		.value_(model[prop]);
		//To do - how to make this read only?
		arControls.add(vwNumberbox);

		//Add the group of controls to the dictionary
		dicControlGroups.put(prop, arControls);

	}


	updateControls {
		arg prop, newValue;
		var controlGroup;
		dicControlGroups keysDo: {| key, index | [key, index].postln};
		controlGroup = dicControlGroups.at(prop);
		controlGroup do: _.postln;
		//Locate and set the slider
		controlGroup.at(0).value_(newValue);
		//Locate and set the Number box
		controlGroup.at(1).value_(newValue);
	}

	//Old stuff. To delete.

	//This creates a button view and a controller to go with a model
	makeOnOffButtonView {
		arg model;
		var view, controller;

		view = Button()
		.states_([
			["Off", Color.black],
			["On", Color.red]
		])
		.action_({
			arg but;
			model.source = but.value;
		})
		.value_(model.source);

		//Create a controller for this view
		controller = SimpleController(model).put(\source, {
			arg obj, what, args;
			defer { view.value = args[0] };
		});

		view.onClose = { controller.remove };

		^view;
	}

	//This creates a slider view and a controller to go with a model
	makeSliderView {
		arg model;
		var view, controller;

		view = Slider()
		.orientation_(\horizontal)
		.background_(Color(1,0.5,0))
		.thumbSize_(40)
		.action_({
			arg slider;
			model.source = slider.value;
		})
		.value_(model.source);

		//Create the controller for this view
		controller = SimpleController(model).put(\source, {
			arg obj, what, args;
			defer { view.value = args[0] };
		});

		view.onClose = { controller.remove };

		^view;
	}

}