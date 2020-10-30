AjmViewMaker {

	//TODO: Implement custom colours as arguments


	*makeSliderGroup {
		arg prop, currentValue, label, window, left, top, setValueFunction;
		var vwLabel, vwSlider, vwNumberbox;

		//Create the static text label for the slider
		vwLabel = StaticText.new(window, Rect(left, top, 100, 20)).string_(label);

		//Create the slider
		vwSlider = Slider.new(window, Rect(left + 100, top, 180, 20))
		.value_(currentValue)
		.action_({
			arg view;
		    setValueFunction.value(prop, view.value);
		});//TODO: this is currently causing a doesn't understand error

		//Create the number box
		vwNumberbox = NumberBox.new(window, Rect(left + 300, top, 44, 20))
		    .value_(currentValue);
		//To do - how to make this read only?

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