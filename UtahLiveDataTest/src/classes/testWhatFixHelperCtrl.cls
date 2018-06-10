@isTest
private class testWhatFixHelperCtrl {
	
	@isTest static void test_method_one() {
		GNT__KeyValueStore__c ea = new GNT__KeyValueStore__c(Name='EnableWhatFix',GNT__TextValue__c='true', GNT__Description__c='This is the Enterprise account that is set in the Role hierarchy the corresponding Account is also created',
                                                    GNT__Admin_Question__c = 'Loren Ipsum');
		insert ea;
		GNT__KeyValueStore__c ea1 = new GNT__KeyValueStore__c(Name='WhatFixEntId',GNT__TextValue__c='true', GNT__Description__c='This is the Enterprise account that is set in the Role hierarchy the corresponding Account is also created',
                                                    GNT__Admin_Question__c = 'Loren Ipsum');
		insert ea1;
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			WhatFixHelperCtrl wfhc = new WhatFixHelperCtrl();
			wfhc.getEnableWhatFix();
			wfhc.getWhatFixEntId();
			wfhc.getOrgName();
			wfhc.getPackageName();
			wfhc.getProfileName();
		}
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}