// This class tests this AjmMidiBinder class

TestAjmMidiBinder : UnitTest {

	//Things to test:
	//- That unbind removes all receivers
	//- That bindExpressionPedals creates 2 bindings
	//- That bindFootSwitch creates 1 binding
	//- TODO what else?

	var testModel;
	var ajmMidiBinder;

	setUp {
		//This code is executed before all tests

		//Create an MVC model with a property
		testModel = Event.new;
		testModel.testProp = 0;

		//Create the midi binder to test
		ajmMidiBinder = AjmMidiBinder.new(testModel);

	}

	tearDown {
		postln("tearDown!");
		//Remove all bindings
		ajmMidiBinder.unbind;
		postln("tearDown is finished!");
	}

	test_initially_has0Bindings {

		//Arrange

		//Act

		//Assert
		this.assertEquals(
			ajmMidiBinder.listReceivers.size,
			0,
			"There should be 0 bindings initially");

		//TODO: this test freezes the interpreter but why?

	}

	test_bindFootSwitch_creates1Binding {

		//Arrange

		//Act
		//Bind a foot switch
		ajmMidiBinder.bindFootSwitch(0, \testProp);

		//Assert
		this.assertEquals(
			ajmMidiBinder.listReceivers.size,
			1,
			"There should be 1 binding");

	}

}