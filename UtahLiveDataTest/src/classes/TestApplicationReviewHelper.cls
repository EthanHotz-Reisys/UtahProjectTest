@isTest
private class TestApplicationReviewHelper {

    static testMethod void testWhenClicked() {
    PreapplicationTriggerHelper.skipTrigger = true;
    ApplicationTriggerHelper.skipTrigger = true;
    AnnouncementTriggerHelper.skipTrigger = true;
    PanelUserTriggerHelper.skipAll= true;
    UserTriggerHelper.skipTrigger = true;
    
    ApplicationReviewHelper extReg= new ApplicationReviewHelper();  
         User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        Test.startTest();
        TestHelper.CreateCustomSettings(true);
        ReviewStep__c rs = TestHelper.getReviewStep(false);
        rs.status__c= 'In Progress';
        insert rs;
        ReviewStepApplication__c rsa = TestHelper.getReviewStepApplication(true);
        // ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',rs.Id);
             
      
            Map<String,String> urlParams = new Map<String,String>();
            urlParams.put('id',rs.Id);
            extReg.urlParams = urlParams;
           
       
         
    
        extReg.clickHandler();
         Test.stopTest();    
    }
   }
   
    static testMethod void testWhenClicked2() {
    PreapplicationTriggerHelper.skipTrigger = true;
    ApplicationTriggerHelper.skipTrigger = true;
    AnnouncementTriggerHelper.skipTrigger = true;
    PanelUserTriggerHelper.skipAll= true;
    UserTriggerHelper.skipTrigger = true;
    
    ApplicationReviewHelper extReg= new ApplicationReviewHelper();  
         User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        Test.startTest();
        TestHelper.CreateCustomSettings(true);
        ReviewStep__c rs = TestHelper.getReviewStep(false);
        rs.status__c= 'Completed';
        insert rs;
        ReviewStepApplication__c rsa = TestHelper.getReviewStepApplication(true);
        // ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',rs.Id);
             
      
            Map<String,String> urlParams = new Map<String,String>();
            urlParams.put('id',rs.Id);
            extReg.urlParams = urlParams;
           
       
         
    
        extReg.clickHandler();
         Test.stopTest();    
    }
   }
    
    static testMethod void testWhenClicked1() {
    PreapplicationTriggerHelper.skipTrigger = true;
    ApplicationTriggerHelper.skipTrigger = true;
    AnnouncementTriggerHelper.skipTrigger = true;
    PanelUserTriggerHelper.skipAll= true;
    UserTriggerHelper.skipTrigger = true;
    
    ApplicationReviewHelper extReg= new ApplicationReviewHelper();  
         User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        Test.startTest();
        TestHelper.CreateCustomSettings(true);
        ReviewStep__c rs = TestHelper.getReviewStep(true);
     
        ReviewStepApplication__c rsa = TestHelper.getReviewStepApplication(false);
        rsa.ReviewStep__c = rs.Id;
        insert rsa;
        // ApexPages.StandardController sc = new ApexPages.standardController(uReg);
         ApexPages.currentPage().getParameters().put('Id',rs.Id);
             
      
            Map<String,String> urlParams = new Map<String,String>();
            urlParams.put('id',rs.Id);
            extReg.urlParams = urlParams;
           
       
         
    
        extReg.clickHandler();
         Test.stopTest();    
    }
    }
    
    
}