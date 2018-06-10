global with sharing class CopyFromExistingHelper extends GNT.DynamicLayoutActionRedirect
{
    global override PageReference whenClicked(){ 
       
         
         Id recordId = layoutHolder.getPrimarySObject().Id;
         Integer appCount,maxAppCount;
         System.debug('The record Id is '+recordId);
         String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c'); 
         User u = [select GNT__OrganizationId__c from User where id =:Userinfo.getUserId()];      
         if(appName == 'Recipient'){  
           
           OpportunityQualification__c qualifiedAnnouncement = [Select Id, FundingOpportunity__r.Name, FundingOpportunity__c,FundingOpportunity__r.MaxApplicationsAllowed__c,ApplicationCreated__c,PreApplicationCreated__c, IsPreapplicationSubmitted__c ,IsPreApplicationRequired__c,FundingOpportunity__r.AllowMultipleApplicationsFromOrg__c from OpportunityQualification__c where id=:recordId limit 1];
             if(qualifiedAnnouncement.IsPreApplicationRequired__c==true && qualifiedAnnouncement.IsPreapplicationSubmitted__c==false){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pre-Application needs to be submitted before creating an application'));  
                return null;
             }
            GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
            List<Application__c> appList = [Select Id, Name from Application__c where Announcement__c=:qualifiedAnnouncement.FundingOpportunity__c and ExternalOrganization__c =:userPrefs.GNT__OrganizationAccountId__c];
            if(appList!=null &&  appList.size()>0){
                appCount = appList.size();
           } else{
                appCount = 0;
            }
            if(qualifiedAnnouncement.FundingOpportunity__r.MaxApplicationsAllowed__c!=null&&qualifiedAnnouncement.FundingOpportunity__r.MaxApplicationsAllowed__c>0){
                maxAppCount=(Integer)qualifiedAnnouncement.FundingOpportunity__r.MaxApplicationsAllowed__c;
            }
            else{
                maxAppCount=1;
            }

            if(maxAppCount<=appCount){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application cannot be created as you have reached the maximum limit for allowed applications for '+qualifiedAnnouncement.FundingOpportunity__r.Name));
                return null;                 
            } 
            
         
        }
        return null ;
    }
}