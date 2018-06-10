@isTest(seealldata =  true)
public class TestPaymentRequestViewCtrl{
    static testMethod void someTest() {
    
        User u = TestHelper.getAdminUser(true);
        PaymentRequest__c payReq = null;
        Grant__c grant = null;
        Award__c awards = null;
        //User u = TestHelper.getAdminUser(true);
        UserRegistrationTriggerHelper.skipTrigger= true;
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;
        ApplicationTriggerHelper.skipTrigger = true;
        ReviewTriggerHelper.skipTrigger = true;   
        AccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        AppUtils.skipStepReviewTrigger = true;  
        PanelUserTriggerHelper.skipAll=true;  
        ReviewStepTriggerHelper.skipTrigger = true;
        ContactTriggerHelper.skipTrigger = true;
        ContactTriggerHelper.skipSyncEmail = true;
        PaymentRequestTriggerHelper.skipTrigger = true;
       
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger=true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(true, pt);
            BusinessPackage__c buspack=new BusinessPackage__c();
            buspack.PackageType__c='PaymentRequest';
            buspack.PackageConfig__c=pack.id;
            buspack.FundingOpportunity__c = ann.Id;
            
        
            grant = TestHelper.getGrant(false);
            grant.SpendType__c = 'Contracts';
          
            insert grant ;
            buspack.Grant__c = grant.Id;
            insert buspack;
            awards = TestHelper.getAwards(grant.Id,true);
            payReq = TestHelper.getPaymentRequest(false);
            payReq.Status__c = 'Approved by Program Manager';
            payReq.Award__c = awards.Id;
            insert payReq;

           
           /* List<BusinessPackage__c> bp = [SELECT PackageConfig__c FROM BusinessPackage__c WHERE PackageType__c=:'PaymentRequest'];
            businessPack = new BusinessPackage__c(Paymentrequest__c=payReq.Id,PackageType__c='PaymentRequest,PackageConfig__c=bp[0].PackageConfig__c);
            insert businessPack; */
        }
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(payReq);
        ApexPages.currentPage().getParameters().put('id',payReq.id);
        PaymentRequestViewCtrl e = new PaymentRequestViewCtrl(sc);
        e.getKeyValueMap();
        e.getListParams();
        Test.stopTest();
    }
}