@isTest(seealldata=true)
private class TestConvertToAnnouncementHelper {
   static testMethod void whenClicked() {
     /*
       FOALead__c fOALead = null;
       User u = new User(Id=UserInfo.getUserId());
        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
             AccountTriggerHelper.skipTrigger=true;
             AnnouncementTriggerHelper.skipTrigger=true;
            fOALead = TestHelper.getFOALead(true);
        }
        
        Test.startTest();
        ConvertToAnnouncementHelper convertToAnnouncementHelper = new ConvertToAnnouncementHelper();
        ApexPages.currentPage().getParameters().put('Id', fOALead.Id);
        convertToAnnouncementHelper.whenClicked();
        Test.stopTest();
        */
    }
    
    static testMethod void whenClicked2() {
    /*
     
       FOALead__c fOALead = null;
       Account acct = null;
       User u = new User(Id=UserInfo.getUserId());
        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
             AccountTriggerHelper.skipTrigger=true;
             AnnouncementTriggerHelper.skipTrigger=true;
            acct = TestHelper.getAccount(true);
            fOALead = new FOALead__c(FundingOppURL__c='/apex/testPageUrl',SourceStatus__c='Open',
                                            Status__c='New Lead',StrategicPlan__c=TestHelper.getStrategicPlan(true).id,
                                            Justification__c='Sample Justification',
                                            RecipientAgency__c=acct.Id,Impact__c='5 - Very High',Relevance__c='5 - Very High');
            insert fOALead;
            
            
        }
        
        Test.startTest();
        ConvertToAnnouncementHelper convertToAnnouncementHelper = new ConvertToAnnouncementHelper();
        ApexPages.currentPage().getParameters().put('Id', fOALead.Id);   
        convertToAnnouncementHelper.whenClicked();
        Test.stopTest();
        */
    }
    
  /*  static testMethod void createAnnouncement(){
        FOALead__c fOALead = null;
        User u = new User(Id=UserInfo.getUserId());
        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger=true;
            fOALead = TestHelper.getFOALead(true);
        }
        
        Test.startTest();
        ConvertToAnnouncementHelper convertToAnnouncementHelper = new ConvertToAnnouncementHelper();
        ApexPages.currentPage().getParameters().put('Id', fOALead.Id);
        convertToAnnouncementHelper.createAnnouncement(fOALead);
        Test.stopTest();
    
    }*/
  
}