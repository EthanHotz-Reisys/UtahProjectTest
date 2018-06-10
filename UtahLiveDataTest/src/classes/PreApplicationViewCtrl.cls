public with sharing class PreApplicationViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public String pkgId {get;set;}
    private Announcement__c announcementObj;
    private PreApplication__c preapplicationObj;
    
    public PreApplicationViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
                  
        preapplicationObj = [SELECT Id, announcement__c FROM PreApplication__c WHERE Id =:recordId LIMIT 1];
        
        announcementObj = [SELECT Id,(select PackageConfig__c from Business_Packages__r where PackageType__c='Pre-Application') FROM Announcement__c WHERE id=:preapplicationObj.announcement__c LIMIT 1];    
        pkgId = announcementObj.Business_Packages__r[0].PackageConfig__c;
        
        /*if (announcementObj.PreApplicationPackage__c != null){
            pageTemplateName = announcementObj.PreApplicationPackage__r.GNT__PageTemplateConfig__r.Name;
        }  */
        String enableSubmit = ApexPages.CurrentPage().getParameters().get('enableSubmit');
        if(!String.isEmpty(enableSubmit)){
            Boolean enableSubmitBool = Boolean.valueOf(enableSubmit);  
            if(enableSubmitBool != null && enableSubmitBool == false){
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Pre-Application does not meet the submission criteria.');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-16377'));
                ApexPages.addMessage(myMsg);
            }
        }
        deleteURL = null; 
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('preapplicationid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}