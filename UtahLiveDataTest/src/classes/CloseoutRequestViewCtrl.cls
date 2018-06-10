public with sharing class CloseoutRequestViewCtrl {
    
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public ID grantId{get;set;}
    public ID awardId{get;set;}
    public String packageId {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    
    public CloseoutRequestViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        Closeout__c closeout = [Select Id, Name, Grant__c from Closeout__c where id =:recordId];
        //applicationObj = [SELECT Id, Announcement__c,OwnerId,Announcement__r.AnnouncementName__c FROM Application__c WHERE Id =:recordId LIMIT 1];
        /*Select Id, Grant__r.
        system.debug('applicationObj------>>>>'+applicationObj.Announcement__c);
        announcementObj = [SELECT Id, ApplicationPackage__r.GNT__PageTemplateConfig__r.Name,Program__c,(select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Application') FROM Announcement__c WHERE id=:applicationObj.announcement__c LIMIT 1];    
        system.debug('announcementObj------>>>>'+announcementObj);*/
        List<BusinessPackage__c> bc = [select PackageConfig__c from BusinessPackage__c where PackageType__c='Closeout' and Grant__c=:closeout.Grant__c];
        if(bc.size() > 0)
        packageId = bc[0].PackageConfig__c;
        
        pageTemplateName='CloseoutRequest';
        Closeout__c cr = [select id, Grant__c,Award__c from Closeout__c where id=:recordId];
        grantId = cr.Grant__c;
        awardId = cr.Award__c;
    } 
    
      public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('closeOutId',recordId);
        keyValueMap.put('id',recordId);          
        keyValueMap.put('grantId',grantId);
        keyValueMap.put('awardId',awardId);
        return JSON.serialize(keyValueMap);
    }

}