// This class tests this AjmViewMaker class

TestAjmViewMaker : UnitTest {

	var testModel;
	var win;
	var ajmViewMaker;

	setUp {
		testModel = Event.new;
		win = Window.new;
	}

	tearDown {
		ajmViewMaker = nil;
		testModel = nil;
		win.close;
	}

	test_initially_has0ControlGroups {
		//Test that dicControlGroups is initially empty.

		//Arrange
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);

		//Act

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.size,
			0,
			"There should be 0 control groups initially"
		);

	}

	test_makeButton_adds1ControlGroup {
		//Test that makeButton adds one group of controls.

		//Arrange
		testModel.prop1 = 0;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);

		//Act
		ajmViewMaker.makeButton(\prop1);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.size,
			1,
			"There should be 1 control group"
		);

	}

	test_makeButton_adds1Control {
		//Test that makeButton adds a group with 1 control in it.

		//Arrange
		testModel.prop1 = 0;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);

		//Act
		ajmViewMaker.makeButton(\prop1);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.at(\prop1).size,
			1,
			"There should be 1 control."
		);

	}

	test_makeButton_addsAButton {
		//Test that makeButton adds a button.

		//Arrange
		testModel.prop1 = 0;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);

		//Act
		ajmViewMaker.makeButton(\prop1);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.at(\prop1).at(0).class.asString,
			"Button",
			"There should be a button."
		);

	}

	test_makeSliderGroup_adds1ControlGroup {
		//That makeSliderGroup adds one control group.

		//Arrange
		testModel.prop1 = 0;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);

		//Act
		ajmViewMaker.makeSliderGroup(\prop1);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.size,
			1,
			"There should be 1 control group"
		);

	}

	test_makeSliderGroup_adds3Controls {
		//Test that makeSliderGroup adds a group with 3 objects in it.

		//Arrange
		testModel.prop1 = 0;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);

		//Act
		ajmViewMaker.makeSliderGroup(\prop1);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.at(\prop1).size,
			3,
			"There should be 3 controls in a slider group."
		);

	}

	test_updateControls_setValueOfButton {
		//Test that update controls sets the value of a button correctly.

		//Arrange
		testModel.prop1 = 0;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);
		ajmViewMaker.makeButton(\prop1);

		//Act
		ajmViewMaker.updateControls(\prop1, 1);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.at(\prop1).at(0).value,
			1,
			"The button should be set to 1"
		);

	}

	test_updateControls_setValueOfSlider {
		//Test that update controls sets the value of a slider correctly.

		//Arrange
		testModel.prop1 = 0.1;
		ajmViewMaker = AjmViewMaker.new(win, testModel, Color.red);
		ajmViewMaker.makeSliderGroup(\prop1);

		//Act
		ajmViewMaker.updateControls(\prop1, 0.5);

		//Assert
		this.assertEquals(
			ajmViewMaker.dicControlGroups.at(\prop1).at(0).value,
			0.5,
			"The slider should be set to 0.5"
		);

	}

}