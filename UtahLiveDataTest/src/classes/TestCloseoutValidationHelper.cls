@isTest
private class TestCloseoutValidationHelper {

    static testMethod void myUnitTest() {
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        GrantTriggerHelper.skipTrigger = true;
        AwardtriggerHelper.skipTrigger=true;
        AmendmentRequestTriggerHelper.skipTrigger=true;
        PaymentRequestTriggerHelper.skipTrigger=true;
        FundingSourceTriggerHelper.skipTrigger=true;
        ProgressReportsTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipAll = true;
        System.runAs(u){
            Grant__c grant = TestHelper.getGrant(true);
            Award__c awd = TestHelper.getAwards(grant.Id,true);
            Closeout__c ct = TestHelper.getcloseout(grant.id,false);
            ct.Award__c = awd.id;
            ct.DueDate__c = Date.Today();
            insert ct;
            Set<Id> awardIds = new Set<Id>();
            Set<Id> grantIds = new Set<Id>(); 
            awardIds.add(ct.Award__c);
            grantIds.add(ct.Grant__c);
            BudgetPeriod__c bp = new BudgetPeriod__c(Grant__c = ct.Grant__c,Status__c = 'Open');
            insert bp;
            AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(Grant__c=ct.Grant__c,Status__c='Approved',Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact',NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
            insert amendmentRequest1;
            PaymentRequest__c pmntreq = new paymentrequest__c(Grant__c=ct.Grant__c,Status__c='Approved by fiscal manager');
            insert pmntreq;
            FundingSource__c fsource = new FundingSource__c(Grant__c=ct.Grant__c,Status__c='Open');
            insert fsource;
            TermCondition__c tc = TestHelper.getTermCondition(true,'Progress Report');
            ProgressReports__c progressrpt = new ProgressReports__c(Award__c = ct.Award__c,TermandCondition__c = tc.id);
            insert progressrpt;
            
            Test.startTest();         
            CloseoutValidationHelper closeout = new CloseoutValidationHelper();
            ApexPages.currentPage().getParameters().put('id',ct.Id);  
            closeout.whenClicked();
            Test.stopTest();
            
        }
    }
    static testMethod void myUnitTest1() {
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        GrantTriggerHelper.skipTrigger = true;
        AwardtriggerHelper.skipTrigger=true;
        AmendmentRequestTriggerHelper.skipTrigger=true;
        PaymentRequestTriggerHelper.skipTrigger=true;
        FundingSourceTriggerHelper.skipTrigger=true;
        ProgressReportsTriggerHelper.skipTrigger=true;
        AccountTriggerHelper.skipAll = true;
        System.runAs(u){
            Grant__c grant = TestHelper.getGrant(true);
            Award__c awd = TestHelper.getAwards(grant.Id,true);
            Closeout__c ct = TestHelper.getcloseout(grant.id,false);
            ct.Award__c = awd.id;
            ct.DueDate__c = Date.Today();
            insert ct;
            Set<Id> awardIds = new Set<Id>();
            Set<Id> grantIds = new Set<Id>(); 
            awardIds.add(ct.Award__c);
            grantIds.add(ct.Grant__c);
            BudgetPeriod__c bp = new BudgetPeriod__c(Grant__c = ct.Grant__c,Status__c = 'Open');
            insert bp;
            AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(Grant__c=ct.Grant__c,Status__c='Approved',Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact',NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
            insert amendmentRequest1;
            PaymentRequest__c pmntreq = new paymentrequest__c(Grant__c=ct.Grant__c,Status__c='Approved by Program Manager');
            insert pmntreq;
            FundingSource__c fsource = new FundingSource__c(Grant__c=ct.Grant__c,Status__c='Open');
            insert fsource;
            TermCondition__c tc = TestHelper.getTermCondition(true,'Progress Report');
            ProgressReports__c progressrpt = new ProgressReports__c(Award__c = ct.Award__c,TermandCondition__c = tc.id);
            insert progressrpt;
            
            Test.startTest();         
            CloseoutValidationHelper closeout = new CloseoutValidationHelper();
            ApexPages.currentPage().getParameters().put('id',ct.Id);  
            closeout.whenClicked();
            Test.stopTest();
            
        }
    }
}