@isTest
private class TestDeepCloneProgramHelper {
	
	@isTest static void test_method_one() {
		AccountTriggerHelper.skipTrigger = true;
		ProgramTriggerHelper.skipTrigger = true;
		ContactTriggerHelper.skipTrigger = true;
		RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
		FundingSourceTriggerHelper.skipTrigger = true;
		FundingAccountTriggerHelper.skipTrigger = true;
		TermConditionTriggerHelper.skipTrigger = true;
		ApplicationTriggerHelper.skipTrigger = true;
		AnnouncementTriggerHelper.skipTrigger = true;


		Announcement__c ann = TestHelper.getAnnouncement(true);
        ann.ApplicationCreatedOutside__c='Yes';
        update ann;

		Application__c app = TestHelper.getApplication(ann.Id,true);
        app.AwardFloor__c=2000;
        app.AwardCeiling__c=1;
        update app;

		String ns = AppUtils.getNamespacePrefix();
		GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
		GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);


		Account account = TestHelper.getAccount(true);
		Program__c program = TestHelper.getProgram(account.Id, true);
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(program);
		DeepCloneProgramHelper d = new DeepCloneProgramHelper(stdController);

		layoutHolder.recordMap = new Map<String, sObject>();
		layoutHolder.recordMap.put('program', program);
		layoutHolder.objName = 'program';
		DeepCloneProgramHelper dcph = new DeepCloneProgramHelper(layoutHolder);
		Contact contact = TestHelper.getContact(true);
		ProgramContacts__c pc = new ProgramContacts__c(Contact__c = contact.Id, Program__c = program.Id);
		insert pc;
		GoalObjective__c go = new GoalObjective__c(Program__c = program.Id);
		insert go;
		KeyOutcome__c ko = new KeyOutcome__c(Program__c = program.Id);
		RolesandResponsibilities__c roleAndRes = TestHelper.getRolesAndResponsibilities(true, program.Id);
		insert ko;
		FundingSource__c fs = TestHelper.getFundingSource(true);
		FundingAccount__c fa = TestHelper.getFundingAccount(true, fs.Id);
		ProgramFundingAccount__c pfa = TestHelper.getProgramFundingAccount(true, fa.Id, program.Id);
		RiskAssessment__c ra = new RiskAssessment__c(Program__c = program.Id);
		insert ra;
		RiskItem__c ri = new RiskItem__c(Program__c = program.Id);
		insert ri;
		TermCondition__c tc = TestHelper.getTermCondition(true, 'Condition');
		tc.Program__c = program.Id;
		update tc;

		GNT__AttachmentExtension__c ae = new GNT__AttachmentExtension__c(GNT__ParentId__c = program.Id);
		insert ae;
		dcph.whenClicked();




	}
	
	@isTest static void test_method_two() {
		DeepCloneProgramHelper dcph = new DeepCloneProgramHelper();

	}
	
	@isTest static void test_method_three() {
		AccountTriggerHelper.skipTrigger = true;
		ProgramTriggerHelper.skipTrigger = true;
		ContactTriggerHelper.skipTrigger = true;
		RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
		FundingSourceTriggerHelper.skipTrigger = true;
		FundingAccountTriggerHelper.skipTrigger = true;
		TermConditionTriggerHelper.skipTrigger = true;
		ApplicationTriggerHelper.skipTrigger = true;
		AnnouncementTriggerHelper.skipTrigger = true;


		Announcement__c ann = TestHelper.getAnnouncement(true);
        ann.ApplicationCreatedOutside__c='Yes';
        update ann;

		Application__c app = TestHelper.getApplication(ann.Id,true);
        app.AwardFloor__c=2000;
        app.AwardCeiling__c=1;
        update app;

		String ns = AppUtils.getNamespacePrefix();
		GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
		GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);


		Account account = TestHelper.getAccount(true);
		Program__c program = TestHelper.getProgram(account.Id, true);
		
		
		layoutHolder.recordMap = new Map<String, sObject>();
		layoutHolder.recordMap.put('program', program);
		layoutHolder.objName = 'program';
		DeepCloneProgramHelper dcph = new DeepCloneProgramHelper(layoutHolder);
		//Contact contact = TestHelper.getContact(true);
		////ProgramContacts__c pc = new ProgramContacts__c(Contact__c = contact.Id, Program__c = program.Id);
		////insert pc;
		////GoalObjective__c go = new GoalObjective__c(Program__c = program.Id);
		////insert go;
		//KeyOutcome__c ko = new KeyOutcome__c(Program__c = program.Id);
		//RolesandResponsibilities__c roleAndRes = TestHelper.getRolesAndResponsibilities(true, program.Id);
		//insert ko;
		//FundingSource__c fs = TestHelper.getFundingSource(true);
		//FundingAccount__c fa = TestHelper.getFundingAccount(true, fs.Id);
		//ProgramFundingAccount__c pfa = TestHelper.getProgramFundingAccount(true, fa.Id, program.Id);
		//RiskAssessment__c ra = new RiskAssessment__c(Program__c = program.Id);
		//insert ra;
		//RiskItem__c ri = new RiskItem__c(Program__c = program.Id);
		//insert ri;
		//TermCondition__c tc = TestHelper.getTermCondition(true, 'Condition');
		//tc.Program__c = program.Id;
		//update tc;

		//GNT__AttachmentExtension__c ae = new GNT__AttachmentExtension__c(GNT__ParentId__c = program.Id);
		//insert ae;
		dcph.whenClicked();




	}
}