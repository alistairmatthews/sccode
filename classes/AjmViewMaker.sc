AjmViewMaker {

	//TODO: Implement custom colours as arguments

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