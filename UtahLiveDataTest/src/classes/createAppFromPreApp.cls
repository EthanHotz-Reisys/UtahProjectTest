global with sharing class createAppFromPreApp extends GNT.DynamicLayoutActionRedirect{
    public createAppFromPreApp() {
        
    }

    global override PageReference whenClicked(){      
        Id recordId = layoutHolder.getPrimarySObject().Id;
        String ns = AppUtils.getNamespacePrefix(); 
        System.debug('The record Id is '+recordId);
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
 
        User u = [select GNT__OrganizationId__c from User where id =:Userinfo.getUserId()];
  //      List<Application__c> applicationList = [SELECT Id,Status__c FROM Application__c WHERE Announcement__c =: recordId AND CreatedBy.Organization__c =:u.organization__c ];//CreatedById =: Userinfo.getUserId()];
        
        if(appName == 'StateasGrantee'){ 
            System.debug('<<<<<<< REDIRECTING TO THE APPLICATION PAGE >>>>>>>');
            return new PageReference('/apex/'+ns+'ApplicationEdit?preAppId=' + recordId );  
        }  
        else
        {
            System.debug('<<<<<<< REDIRECTING TO THE APPLICATION PAGE >>>>>>>');
            return new PageReference('/apex/'+ns+'ApplicationEdit?preAppId=' + recordId );  
            
        }

            return null; 
    }
}