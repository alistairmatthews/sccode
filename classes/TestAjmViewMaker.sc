// This class tests this AjmViewMaker class

TestAjmViewMaker : UnitTest {

	//Things to test:
	//1. That dicControlGroups is initially empty. Done
	//2. That makeButton adds one group. Done
	//3. That makeButton adds a group with 1 button in it
	//4. That makeSliderGroup adds one group
	//5. That makeSliderGroup adds a group with 3 objects in it
	//6. That update controls changes the value of a button
	//7. That update controls changes the value of a slider


	test_initially_has0ControlGroups {

		//Arrange

		~testModel = Event.new;
		~win = Window.new;
		~ajmViewMaker = AjmViewMaker.new(~win, ~testModel, Color.red);

		//Act

		//Assert
		this.assertEquals(
			~ajmViewMaker.dicControlGroups.size,
			0,
			"There should be 0 control groups initially"
		);

	}

	test_makeButton_adds1ControlGroup {

		//Arrange

		~testModel = Event.new;
		~testModel.prop1 = 0;
		~win = Window.new;
		~ajmViewMaker = AjmViewMaker.new(~win, ~testModel, Color.red);

		//Act
		~ajmViewMaker.makeButton(\prop1);

		//Assert
		this.assertEquals(
			~ajmViewMaker.dicControlGroups.size,
			1,
			"There should be 1 control group"
		);

	}

}