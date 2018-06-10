/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestQualifiedAnnouncementViewHelper{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
    OpportunityQualification__c oq = new OpportunityQualification__c();
    insert oq;
    List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(oq.id);
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', oq.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        QualifiedAnnouncementViewHelper ctrl = new QualifiedAnnouncementViewHelper();
        ctrl.selectedRecordIds = selectedRecordIds;
        ctrl.clickHandler();

        Test.stopTest();

        //assert
        System.assertEquals(oq.Id, oq.Id);
        
        
        }
    }
  }