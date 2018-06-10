@isTest
private class TestSendToSubrecipientHelper {
    @isTest static void test_method_one(){
        SiteVisitTriggerHelper.skipTrigger= true;
        GrantTriggerHelper.skipTrigger=true;
        AwardTriggerHelper.skipTrigger=true;
        UserTriggerHelper.skipTrigger=true;
        SiteVisit__c sv= TestHelper.getSiteVisit(true);
        SiteVisitActivity__c sva= TestHelper.getSiteVisitActivity(true);
       Test.startTest();
        	System.debug('Started test');
            ApexPages.currentPage().getParameters().put('id',sv.Id);
            SendToSubrecipientHelper sendtosubrecipienthelper = new SendToSubrecipientHelper();
            sendtosubrecipienthelper.whenClicked();
            ApexPages.currentPage().getParameters().put('id',sva.SiteVisit__c);
            sendtosubrecipienthelper.whenClicked();
            System.debug('Ended test');
        Test.stopTest();
    }
    
}