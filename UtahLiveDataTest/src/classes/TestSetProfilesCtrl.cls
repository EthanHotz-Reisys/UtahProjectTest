@isTest(SeeAllData=false)
private class TestSetProfilesCtrl{

    @isTest
    static void myUnitTest1() {  
    
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
        
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
             
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('id',app.Id);
            ApexPages.CurrentPage().getParameters().put('field','Announcement__c');
            ApexPages.CurrentPage().getParameters().put('type','Application__c');
            ApexPages.CurrentPage().getParameters().put('profiles','[System Admin,Portal User]');
            SetProfilesCtrl ctrl = new SetProfilesCtrl();   
            SetProfilesCtrl.getProfiles();
            SetProfilesCtrl.save('Application__c',app.Id,'Announcement__c','[System Admin,Portal User]');        
            Test.stopTest();     
        }          
    }    
}