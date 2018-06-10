@isTest
private class TestAnnFundngAccountActionHandler {
    static testMethod void myUnitTest() {
        
        AnnouncementTriggerHelper.skipTrigger = true;
        FundingAccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            
            UserTriggerHelper.skipTrigger = true;
            Announcement__c ann=TestHelper.getGrantorAnnouncement(true); 
            FundingSource__c fundSrc = TestHelper.getFundingSource(true);
            FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
            AnnouncementFundingAccount__c annfndaccnt = new AnnouncementFundingAccount__c(Announcement__c = ann.id,FundingAccount__c = fundAcc.id);
            insert annfndaccnt;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(fundAcc.id);
            ApexPages.currentPage().getParameters().put('Id', ann.Id);
            Map<String,String> urlParams = new Map<String,String>();
            AnnouncementFundingAccountsActionHandler annfaactionhandler = new AnnouncementFundingAccountsActionHandler();
            annfaactionhandler.selectedRecordIds = selectedRecordIds;
            urlParams.put('parentid',ann.Id);
            annfaactionhandler.urlParams = urlParams;
            annfaactionhandler.clickHandler();           
        }
    
    
    }

}