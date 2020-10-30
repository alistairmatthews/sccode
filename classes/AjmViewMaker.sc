AjmViewMaker {

	//TODO: Implement custom colours as arguments

	//The window where we'll create the controls
	var <>window;
	//The MVC model (an sc event)
	var <>model;
	//The dictionary of updateable controls
	var dicControls;

	*new {
		arg win, mod;
		//Create the dictionary of controls to update
		dicControls = Dictionary.new();
		//store the window and the model
		^super.new.window_(win).model_(mod);
	}


	makeSliderGroup {
		arg prop, label, left, top;
		var vwLabel, vwSlider, vwNumberbox;

		//Create the static text label for the slider
		vwLabel = StaticText.new(window, Rect(left, top, 100, 20)).string_(label);

		//Create the slider
		vwSlider = Slider.new(window, Rect(left + 100, top, 180, 20))
		.value_(model[prop])
		.action_({
			arg view;
			~setValueFunction.value(model[prop], view.value);
		}); //This works fine but the MVC controller doesn't set this slider or the number box
		dicControls.put(prop + "Slider", vwSlider);

		//To fix this store all views in an array or something here
		//Then create a method to update those views
		//then call that method from the MVC controller

		//Create the number box
		vwNumberbox = NumberBox.new(window, Rect(left + 300, top, 44, 20))
		.value_(model[prop]);
		//To do - how to make this read only?
		dicControls.put(prop + "Numberbox", vwNumberbox);

	}


	updateControls {
		arg prop, newValue;
		//Locate and set the slider
		dicControls.at(prop + "Slider").value_(newValue);
		//Locate and set the Number box
		dicControls.at(prop + "Numberbox").value(newValue);
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