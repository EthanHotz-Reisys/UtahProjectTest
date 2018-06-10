@isTest
private class TestInitiateAwardHelper {
    /*
       @isTest static void testWhenClicked() {  
       Announcement__c ann=null;
       ReviewStepTemplate__c review = null;
       Application__c app=null;
       BusinessPackage__c businessPack = null;
       User u = new User(Id=UserInfo.getUserId());
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AnnouncementTriggerHelper.skipTrigger=true;
            ann=TestHelper.getGrantorAnnouncement(true);
            app = TestHelper.getGrantorApplication(ann.Id,true);
            ApexPages.currentPage().getParameters().put('id',app.Id);
            GNT.TriggerHelper.skipTrigger=true;
            
            String bodyStr=' title' + '\n' + ' notes';                
            Attachment att=new Attachment();
             att.Body=Blob.valueOf(bodyStr);
             att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
             att.parentId=app.id;
             insert att;
            GNT__AttachmentExtension__c ga = new GNT__AttachmentExtension__c(GNT__Attachment__c = att.Id);
            insert ga;
        
        Test.startTest();
        GNT__PageLayoutConfig__c pagelayoutConfig= null;
        pagelayoutConfig = TestHelper.getPageLayoutConfig(true,'Application__c');
        GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true); 
        InitiateAwardHelper awdHelper = new InitiateAwardHelper();
        awdHelper.whenClicked();
        Test.stopTest();
      }
        
    }  
    
   @isTest static void testWhenClicked1() {  
       User u = new User(Id=UserInfo.getUserId());
       



        System.runAs(u){
        
          Test.startTest();
          InitiateAwardHelper awdHelper = new InitiateAwardHelper();
          awdHelper.whenClicked();
          Test.stopTest();
      }
        
    }  
    */
}