/**
	Test class for ProgramTrigger
	**********************************************************
	Audit History
	**********************************************************
	4/27/2014   Someone	  Created
	**********************************************************  
*/
@isTest
private with sharing class TestProgramTrigger {

	@IsTest(OnInstall=false)
	private static void modifyMyName() {
		//Prepare test data
		
		Test.startTest();

		//Execute test

		Test.stopTest();

		//Assert test data
		System.assertEquals(true, true);
	}
}