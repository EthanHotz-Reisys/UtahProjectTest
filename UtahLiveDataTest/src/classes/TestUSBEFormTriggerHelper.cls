@isTest
private with sharing class TestUSBEFormTriggerHelper {

	static testMethod void testupdateMOEFields() {

		UserTriggerHelper.skipTrigger = true;
		ApplicationTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        USBEForm__c form=new USBEForm__c();
        GNT__PageTemplate__c configForm=TestHelper.getPageTemplateConfig(true);
        configForm.name='MOEForm';
        update configForm;
        Announcement__c ann = TestHelper.getAnnouncemenT((True));
        form.configForm__c=configForm.Id;
        Application__c app = TestHelper.getApplication(ann.Id,false);
        Account acc=TestHelper.getAccount(false);
        app.ExternalOrganization__c=acc.Id;
        insert app;
        form.Application__c=app.Id;
        FiscalYear__c year=new FiscalYear__c();
        insert year;
        MOE__c moeObject=new MOE__c(LEA__c=acc.Id,MetMOE1__c='YES',MetMOE2__c='YES',MetMOE3__c='YES',MetMOE4__c='YES',
        PriorYearLevelOfEffort1__c=1000,PriorYearLevelOfEffort2__c=1000,PriorYearLevelOfEffort3__c=1000,PriorYearLevelOfEffort4__c=1000,
        RequiredLevelOfEffort1__c=1000,RequiredLevelOfEffort2__c=1000,RequiredLevelOfEffort3__c=1000,RequiredLevelOfEffort4__c=1000, Year__c=year.Id);
        insert moeObject;
        
        System.runAs(u){
            Test.startTest();  
            insert form;
            Test.stopTest();
        }

	}

    @isTest static void LEAPrivateSchoolItemTests() {
        UserTriggerHelper.skipTrigger = true;
        user u = TestHelper.getAdminUser(true);
        system.runAs(u) {
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;

            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);

            Account acc = TestHelper.getAccount(false);
            app.ExternalOrganization__c = acc.Id;
            upsert app;

            LEAPrivateSchool__c school = new LEAPrivateSchool__c(
                LEA__c = acc.Id
            );
            insert school;

            GNT__PageTemplate__c configForm=TestHelper.getPageTemplateConfig(true);
            configForm.name='LEAPrivateSchoolForm';
            update configForm;

            USBEForm__c form = new USBEForm__c(
                Application__c = app.Id,
                ConfigForm__c = configForm.Id
            );
            Test.startTest();
            insert form;

            form.FormsValidated__c = true;
            try {
                update form;
            } catch (Exception e) {
                Boolean errorThrown = (e.getMessage().contains('Participation field is required for all schools.')) ? true : false;
                System.AssertEquals(errorThrown, true);
            }

            Test.stopTest();
        }
    }
}