public with sharing class SiteVisitViewCtrl {

 //Properties
    //Shah CRF: declare variables as public only if they are used outside the class. Default should be private.
    public ID recordId{get;set;}
    public string pageTemplate {get;set;}
    private SiteVisit__c siteVisit;   
    public String packageId {get;set;}
    public ID organizationId {get;set;}
    private String grantId;
    private SiteVisit__c sv;

    public SiteVisitViewCtrl (ApexPages.StandardController controller) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplate='GranteeSiteVisit';

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        System.debug('appName===>>'+appName);
        
        if(recordId != null){
            sv = [SELECT Award__r.Application__r.Announcement__c, Grant__c,Grant__r.InternalOrganization__c,Grant__r.Program__c FROM SiteVisit__c WHERE Id =: recordId];
            grantId = sv.Grant__c;
            organizationId=sv.Grant__r.InternalOrganization__c;
        }
        List<BusinessPackage__c> bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Site Visit' and PackageConfig__r.GNT__CustomAppConfig__r.Name =: appName and Grant__c =:grantId];
        if(bizPkg!=null && bizPkg.size()>0) {
            packageId=bizPkg[0].PackageConfig__c;
        }
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('siteVisitId',recordId); 
        keyValueMap.put('orgId',organizationId);     
         System.debug('**organizationId===>>'+organizationId);    
        return JSON.serialize(keyValueMap);
    }
}