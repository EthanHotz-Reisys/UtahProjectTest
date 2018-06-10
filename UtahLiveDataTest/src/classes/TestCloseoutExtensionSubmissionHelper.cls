@isTest
private class TestCloseoutExtensionSubmissionHelper {

    static testMethod void myUnitTest() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GrantTriggerHelper.skipTrigger = true;
        AwardtriggerHelper.skipTrigger=true;
        System.runAs(u){
            Grant__c grant = TestHelper.getGrant(true);
            Award__c awd = TestHelper.getAwards(grant.Id,true);
            Closeout__c ct = TestHelper.getcloseout(grant.id,false);
            ct.Award__c = awd.id;
            ct.DueDate__c = Date.Today();
            ct.ExtensionDays__c = 2;
            insert ct;
            ct.Status__c = 'Notification Acknowledged'; 
            ct.RecipientAccepted__c = true; 
            update ct; 
            Test.startTest();         
            CloseoutExtensionSubmissionHelper closeout = new CloseoutExtensionSubmissionHelper(); 
            ApexPages.currentPage().getParameters().put('id',ct.Id);  
            closeout.whenClicked(); 
            Test.stopTest();
            
        }
    
    }
}