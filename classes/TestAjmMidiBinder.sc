// This class tests this AjmMidiBinder class

TestAjmMidiBinder : UnitTest {

	//Things to test:
	//- That bindExpressionPedals creates 1 binding. Done!
	//- That bindFootSwitch creates 1 binding. Done!
	//- That a binding responds to a mocked program message
	//- TODO what else?

	//TODO: Whenever you try to run more than one test
	//the interpreter crashes but why?
	//The tearDown appears to run and complete correctly
	//Using assert instead of assertEquals didn't help
	//The problem doesn't affect other test classes
	//Doesn't that mean it's a problem with the Midi bit?

	var testModel;
	var ajmMidiBinder;

	setUp {
		//This code is executed before all tests

		//Create an MVC model with a property
		testModel = Event.new;

		//Create the midi binder to test
		ajmMidiBinder = AjmMidiBinder.new(testModel);

	}

	tearDown {
		//Remove all bindings
		MIDIdef.freeAll;
		//free the client
		MIDIClient.free;
	}

	test_initially_has0Bindings {

		//Arrange

		testModel.testProp = 0;

		//Act

		//Assert
		this.assertEquals(
			MIDIdef.all.size,
			0,
			"There should be 0 bindings initially");

	}

	test_bindFootSwitch_creates1Binding {

		//Arrange
		testModel.testProp = 0;

		//Act
		//Bind a foot switch
		ajmMidiBinder.bindFootSwitch(0, \testProp);

		//Assert
		this.assertEquals(
			MIDIdef.all.size,
			1,
			"There should be 1 binding");

	}

	test_bindExpressionPedals_creates1Binding {

		//Arrange
		testModel.testProp1 = 0;
		testModel.testProp2 = 1;

		//Act
		//Bind an expression pedal
		ajmMidiBinder.bindExpressionPedals(\testProp1, \testProp2);

		//Assert
		this.assertEquals(
			MIDIdef.all.size,
			1,
			"There should be 1 binding");

	}

}