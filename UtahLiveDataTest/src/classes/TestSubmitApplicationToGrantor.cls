@isTest
private class TestSubmitApplicationToGrantor {
    
   
    
    static testMethod void someTest() {
        UserTriggerHelper.skipTrigger=true;
        User usr = TestHelper.getAdminUser(true);
        
        system.runas(usr){          
            AppUtils.skipDohApplicationTrigger=true;
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c a = TestHelper.getSubmittedApplication(ann.Id,false);
            a.Status__c ='Approved';
            a.SubmitToGrants__c=true;
            insert a;
            GNT.KeyValueStoreHelper.setTextValue('GrantsGovIntegrationUrl','http://www.grantsgov.com',true);
             GNT.KeyValueStoreHelper.setTextValue('GrantsGovIntegrationKey','Key1',true);
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',a.id);
            MockExternalInterfaceCtrlResponse.indicator = '200';
            MockExternalInterfaceCtrlResponse.indicatorHeader = 'urlencoded';
            MockExternalInterfaceCtrlResponse.indicatorStatus = 'Pass';
            Test.setMock(HttpCalloutMock.class, new MockExternalInterfaceCtrlResponse());  
            SubmitApplicationToGrantor e = new SubmitApplicationToGrantor();   
           PageReference p = e.whenClicked();                                
        }
    }
    
    static testMethod void someTest1() {
        UserTriggerHelper.skipTrigger=true;
        User usr = TestHelper.getAdminUser(true);
        
        system.runas(usr){
            
            AppUtils.skipDohApplicationTrigger=true;
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c a = TestHelper.getSubmittedApplication(ann.Id,false);
            a.Status__c ='Submitted to Grantor'; 
            insert a;
            
           ApexPages.currentPage().getParameters().put('id',a.id);
           SubmitApplicationToGrantor e = new SubmitApplicationToGrantor();            
          PageReference p =e.whenClicked();
                                   
        }
    }
    
    static testMethod void someTest2() {
        UserTriggerHelper.skipTrigger=true;
        User usr = TestHelper.getAdminUser(true);
        
        system.runas(usr){          
            AppUtils.skipDohApplicationTrigger=true;
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c a = TestHelper.getSubmittedApplication(ann.Id,false);
            a.Status__c ='Approved';
         
            insert a;
            
            ApexPages.currentPage().getParameters().put('id',a.id);
            SubmitApplicationToGrantor e = new SubmitApplicationToGrantor();
            PageReference p = e.whenClicked();                                
        }
    }
    
}