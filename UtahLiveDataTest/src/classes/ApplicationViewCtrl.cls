public with sharing class ApplicationViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public String packageId {get;set;}
    private Announcement__c announcementObj;
    private Application__c applicationObj;
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public ID organizationId {get;set;}
    public ID AnnId{get;set;}

    
    public ApplicationViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        system.debug('recordId------>>>>'+recordId);         
        applicationObj = [SELECT Id,ExternalOrganization__c,Approver__c, Announcement__c,OwnerId,Announcement__r.AnnouncementName__c, GrantorOrganizationName__c  FROM Application__c WHERE Id =:recordId LIMIT 1];
        organizationId= applicationObj.ExternalOrganization__c;
        AnnId=applicationObj.Announcement__c;
        system.debug('AnnId------>>>>'+AnnId);  
        system.debug('applicationObj------>>>>'+applicationObj.Announcement__c);
        announcementObj = [SELECT Id, Program__c, (select PackageConfig__r.Name from Business_Packages__r where (PackageType__c='Application' OR PackageType__c='ApplicationUSBE')) FROM Announcement__c WHERE id=:applicationObj.Announcement__c LIMIT 1];    
        //system.debug('announcementObj------>>>>'+announcementObj);
        //system.debug('check this'+announcementObj.Business_Packages__r[0].PackageConfig__c);
        if(announcementObj.Business_Packages__r != null && announcementObj.Business_Packages__r.size() != 0){
            packageId = announcementObj.Business_Packages__r[0].PackageConfig__c;
        }else{
            packageId = '';
        }
        System.debug('packageId------->' + packageId);
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        system.debug('appName------>>>>'+appName);

        if (applicationObj.GrantorOrganizationName__c == 'USBE') {
            pageTemplateName = 'ApplicationTemplateUSBE';
        }
        else if(appName == 'Recipient'){
            pageTemplateName='Application template Grantor';
        }
        else if(appName == 'StateasGrantor') {
            //pageTemplateName='Internal Application template Grantor';
            pageTemplateName='Application template Grantor';
        }
        else{
             pageTemplateName='Application template Grantor';
        }
        String enableSubmit = ApexPages.CurrentPage().getParameters().get('enableSubmit');
        if(!String.isEmpty(enableSubmit)){
            Boolean enableSubmitBool = Boolean.valueOf(enableSubmit);  
            if(enableSubmitBool != null && enableSubmitBool == false){
                if (!Test.isRunningTest()) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-53585'));
                    ApexPages.addMessage(myMsg);
                }
            }
        }

        String crSubmit = ApexPages.CurrentPage().getParameters().get('SR');
        if(!String.isEmpty(crSubmit)){
            if (!Test.isRunningTest()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, GNT.KeyValueStoreHelper.getTextValue('ChangeRequestSubmissionSuccess',true)); 
                ApexPages.addMessage(myMsg);
            }
        }

        
        deleteURL = null; 
    }
    
    public string getKeyValueMap(){
        
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('parentOwnerId',applicationObj.OwnerId); 
        keyValueMap.put('announcementId',announcementObj.Id);
        keyValueMap.put('programId',announcementObj.Program__c);
        keyValueMap.put('orgId',organizationId);
        keyValueMap.put('AnnId',AnnId);
        String userType;
        User user = [SELECT id, IsExternalUser__c,GNT__OrganizationId__c FROM User WHERE id=:UserInfo.getUserId()];
        system.debug('user------'+user);
        if(user.IsExternalUser__c){
            userType = 'External';
        }else
            userType = 'Internal';
        keyValueMap.put('orgName',user.GNT__OrganizationId__c);
        keyValueMap.put('userType',userType);
        keyValueMap.put('userid',user.id);
        return JSON.serialize(keyValueMap);
    }
}