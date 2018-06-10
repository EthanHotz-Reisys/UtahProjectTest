@isTest
private class TestTermConditionTriggerHelper {
    
    @isTest static void test_method_one() {

        //skip unwanted triggers
        GranttriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);

        Grant__c grant = TestHelper.getGrant(true);        
        Award__c awd = TestHelper.getAwards(grant.Id,true);
        GNT__CustomApp__c customConfig = new GNT__CustomApp__c();
        customConfig.Name = 'StateasGrantor';
        customConfig.GNT__Abbreviation__c = 'GRNTR';
        customConfig.GNT__Active__c = true;
        insert customConfig;

        GNT__PhaseConfig__c phaseConfig = TestHelper.getPhase(false);
         phaseConfig.Name = 'TestPhase';
        phaseConfig.GNT__TabName__c='PLANNING';
        phaseConfig.GNT__CustomAppName__c = customConfig.Name;
        phaseConfig.GNT__URL__c = '/apex/planning';
        phaseConfig.GNT__GroupName__c='2';
        phaseConfig.GNT__Sequence__c=2;
        phaseConfig.GNT__Abbreviation__c ='PL';
        phaseConfig.GNT__SObject__c = 'Accouncement__c;Program__c;Package__c'; 
        phaseConfig.GNT__AccordionHeader__c = 'Planning';
        phaseConfig.GNT__EnableSearch__c = true;
        phaseConfig.GNT__SidebarSearchLabel__c = 'Search';
        phaseConfig.GNT__SidebarRecentlyViewedLabel__c = 'Recently Viewed';
        phaseConfig.GNT__SidebarExternalLinksLabel__c = 'External Links';     
        phaseConfig.GNT__SearchResultPage__c ='/apex/planning';
        phaseConfig.GNT__SidebarComponentSequence__c = 'Search,Links,RecentlyViewed,SubMenu';
        phaseConfig.GNT__EnableExternalLinks__c = true;
     phaseConfig.GNT__FlexTableParameters__c = 'orgType=Organization';
        phaseConfig.GNT__Active__c= true;
        phaseConfig.GNT__PhaseType__c = 'Phase';
        phaseConfig.GNT__SelectedByDefault__c = true;
        insert phaseConfig;
        

        List<GNT__ErrorMessageConfig__c> errorMessages = new List<GNT__ErrorMessageConfig__c>();
        GNT__ErrorMessageConfig__c errorMessage1 = new GNT__ErrorMessageConfig__c();
        errorMessage1.Name = 'Some test1';
        errorMessage1.GNT__ErrorCode__c = 'P26-GRNTR-49003';
        errorMessage1.GNT__Message__c = 'Some Error Message1';
        errorMessage1.GNT__Message_Type__c = 'Error';
        errorMessage1.MessageType__c = 'Error';
        errorMessage1.GNT__CustomAppConfig__c = customConfig.Id;
        errorMessage1.GNT__PhaseConfig__c = phaseConfig.Id;
        errorMessage1.GNT__InternalUniqueID__c = 's9by4sZfZsw3IZvdH6TEudv8mf8p3D';

        GNT__ErrorMessageConfig__c errorMessage2 = new GNT__ErrorMessageConfig__c();
        errorMessage2.Name = 'Some test2';
        errorMessage2.GNT__ErrorCode__c = 'P26-GRNTR-83297';
        errorMessage2.GNT__Message__c = 'Some Error Message2';
        errorMessage2.GNT__Message_Type__c = 'Error';
        errorMessage2.MessageType__c = 'Error';
        errorMessage2.GNT__CustomAppConfig__c = customConfig.Id;
        errorMessage2.GNT__PhaseConfig__c = phaseConfig.Id;

        GNT__ErrorMessageConfig__c errorMessage3 = new GNT__ErrorMessageConfig__c();
        errorMessage3.Name = 'Some test2';
        errorMessage3.GNT__ErrorCode__c = 'P26-GRNTR-24373';
        errorMessage3.GNT__Message__c = 'Some Error Message2';
        errorMessage3.GNT__Message_Type__c = 'Error';
        errorMessage3.MessageType__c = 'Error';
        errorMessage3.GNT__CustomAppConfig__c = customConfig.Id;
        errorMessage3.GNT__PhaseConfig__c = phaseConfig.Id;

        GNT__ErrorMessageConfig__c errorMessage4 = new GNT__ErrorMessageConfig__c();
        errorMessage4.Name = 'Some test2';
        errorMessage4.GNT__ErrorCode__c = 'P26-GRNTR-96127';
        errorMessage4.GNT__Message__c = 'Some Error Message2';
        errorMessage4.GNT__Message_Type__c = 'Error';
        errorMessage4.MessageType__c = 'Error';
        errorMessage4.GNT__CustomAppConfig__c = customConfig.Id;
        errorMessage4.GNT__PhaseConfig__c = phaseConfig.Id;

        GNT__ErrorMessageConfig__c errorMessage5 = new GNT__ErrorMessageConfig__c();
        errorMessage5.Name = 'Some test2';
        errorMessage5.GNT__ErrorCode__c = 'P26-GRNTR-85584';
        errorMessage5.GNT__Message__c = 'Some Error Message2';
        errorMessage5.GNT__Message_Type__c = 'Error';
        errorMessage5.MessageType__c = 'Error';
        errorMessage5.GNT__CustomAppConfig__c = customConfig.Id;
        errorMessage5.GNT__PhaseConfig__c = phaseConfig.Id;

        GNT__ErrorMessageConfig__c errorMessage6 = new GNT__ErrorMessageConfig__c();
        errorMessage6.Name = 'Some test2';
        errorMessage6.GNT__ErrorCode__c = 'P26-GRNTR-66042';
        errorMessage6.GNT__Message__c = 'Some Error Message2';
        errorMessage6.GNT__Message_Type__c = 'Error';
        errorMessage6.MessageType__c = 'Error';
        errorMessage6.GNT__CustomAppConfig__c = customConfig.Id;
        errorMessage6.GNT__PhaseConfig__c = phaseConfig.Id;

        errorMessages.add(errorMessage1);
        errorMessages.add(errorMessage2);
        errorMessages.add(errorMessage3);
        errorMessages.add(errorMessage4);
        errorMessages.add(errorMessage5);
        errorMessages.add(errorMessage6);

        insert errorMessages;
                
        List<TermCondition__c> termConditions = new List<TermCondition__c>();
        
        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.TermCondition__c,'Payment Request');
        Id recTypeId1 = TestHelper.getRecordType(Schema.SObjectType.TermCondition__c,'Reporting Requirement');


        Termcondition__c termCondition1 = new TermCondition__c();
        termCondition1.Award__c = awd.Id;
        termCondition1.CalReportingEndDate__c = System.today() + 7;
        termCondition1.CalReportingStartDate__c = system.today() +1;
        termCondition1.ReportName__c = 'Progress 1';
        termCondition1.Category__c = 'Federal Financial Report';
        termCondition1.Frequency__c = 'Fixed';
        termCondition1.RecordTypeId = recTypeId1;
        insert termCondition1;

        TermCondition__c termCondition = new TermCondition__c();
        termCondition.Award__c = awd.Id;
        termCondition.Frequency__c = 'Fixed';
        termCondition.SubmissionRequired__c = true;
        termCondition.RecordTypeId = recTypeId;
        termCondition.Category__c = 'Federal Financial Report';
        termCondition.ReportName__c = 'Progress 1';
        termCondition.CalReportingEndDate__c = System.today() + 7;
        termCondition.CalReportingStartDate__c = system.today() +1;
        insert termCondition;

        
     /*   termConditions.add(termCondition);
        termConditions.add(termCondition1);

        insert termConditions;*/

        system.runAs(u) {
            Test.startTest();
                TermConditionTriggerHelper termConditionTriggerHelper = new TermConditionTriggerHelper();
            Test.stopTest();
        }
    }
}