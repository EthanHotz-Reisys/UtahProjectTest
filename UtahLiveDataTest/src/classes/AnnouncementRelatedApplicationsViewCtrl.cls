public with sharing class AnnouncementRelatedApplicationsViewCtrl{
    public String flexTableHeader {get;set;}
    public string announcementId {get;set;}
    
    public AnnouncementRelatedApplicationsViewCtrl(){
        announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
        checkIfAnnouncementHasApplications();
    }
    
    private void checkIfAnnouncementHasApplications(){
        List<Application__c> appList= [SELECT id,Name FROM Application__c WHERE Announcement__c=:announcementId];
        if(appList != null && appList.size() > 0){
          
        }
         else{
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.warning, 'No Application created for this Annoucement.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.warning, GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-39204')));      
        }
    }
    
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        Set<String> appIdSet = new Set<String>();
        //User u = [SELECT Id,Name,AccountId FROM User WHERE Id=:UserInfo.getUserId()];
        List<Application__c> appList= [SELECT id,Name,ExternalOrganization__c  FROM Application__c WHERE Announcement__c=:announcementId];
        if(appList != null && appList.size() > 0){
            for(Application__c app : appList){
                appIdSet.add(app.id);
            }
        }
       
        listParams.put('applicationIds',appIdSet);
        return JSON.serialize(listParams);
    }
}