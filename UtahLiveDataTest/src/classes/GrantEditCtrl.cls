/**
* Edit page controller for the Grant__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/19/2014    Kunal Shah       Created
* =============================================================================
*/

public with sharing class GrantEditCtrl {
    
    //properties
    public ID recordId{get;set;} 
    private Id pageDataHolder;
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private Application__c applicationObj;
    private Account accnt;
    private Grant__c grant;
    private String title {get;set;}
    private String abbreviation {get;set;}
    public String PageTemplateName {get;set;}
    public GrantEditCtrl(ApexPages.StandardController stdController){
        
        List<User> userlist = new List<User>();
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        abbreviation = ApexPages.CurrentPage().getParameters().get('ProjectTitle__c');
        title = ApexPages.CurrentPage().getParameters().get('GrantAbbreviation__c');
        Id applicationid = ApexPages.CurrentPage().getParameters().get('applicationid');
        pageDataHolder = ApexPages.CurrentPage().getParameters().get('pageDataHolder');
        userlist = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId()];
        accnt = [Select id from Account where id=:(ID)userlist[0].GNT__OrganizationId__c];
        if(pageDataHolder != null) {
            grant = (Grant__c)AppUtils.getSObjectFromJSON();    
        }
        if(recordId != null) {
            List<String> fields = new List<String>();
            fields.add('SpendType__c');
            fields.add('ExternalOrgName__c');
            if(!Test.isRunningTest()){
                stdController.addFields(fields);
                grant = (Grant__c) stdController.getRecord();
            }else{
                grant = new Grant__c();
            }
        }
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        PageTemplateName = getPageTemplateName();
        system.debug('***grant' + grant);
        savePage = Page.GrantView;
        savePage.getParameters().put('id', recordId);
        if (cancelPage == null && recordId != null) {
            cancelPage = Page.GrantView;  
            cancelPage.getParameters().put('id', recordId); 
        }
        else {
            String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            if(retURL != null) {
                cancelPage = new PageReference(retURL);    
            }
        }
        system.debug('***applicationid'+applicationid);
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        /*(if(SpendType__c != null){
            GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SpendType__c',spendType,true);
            listDefaultValues.add(dv13);  
        }*/
        if(title != null){
            GNT.DynamicLayoutDefaultValueHelper dv14 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectTitle__c',title,true);
            listDefaultValues.add(dv14);  
        }
        if(abbreviation != null){
            GNT.DynamicLayoutDefaultValueHelper dv15 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GrantAbbreviation__c',abbreviation,true);
            listDefaultValues.add(dv15);  
        }
        
        if(applicationid !=null){
        applicationObj = [SELECT ExternalOrganization__c,FederalAwardingAgency__c,
                          FederalProgram__c,ProjectPeriodEndDate__c,ProjectPeriodStartDate__c,StateProgram__c ,
                          Title__c,ConstructionPackageIncluded__c FROM Application__c WHERE id=:applicationid]; 
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationid,true);
        listDefaultValues.add(dv); 
        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectTitle__c',applicationObj.Title__c,true);
        listDefaultValues.add(dv1); 
        GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalProgram__c',applicationObj.FederalProgram__c,true);
        listDefaultValues.add(dv3); 
        GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrganization__c',applicationObj.FederalAwardingAgency__c,true);
        listDefaultValues.add(dv4); 
        GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'InternalOrganization__c',applicationObj.ExternalOrganization__c,true);
        listDefaultValues.add(dv6); 
        GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodStartDate__c',applicationObj.ProjectPeriodStartDate__c,true);
        listDefaultValues.add(dv7); 
        GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodEndDate__c',applicationObj.ProjectPeriodEndDate__c,true);
        listDefaultValues.add(dv8);
        GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',applicationObj.StateProgram__c,true);
        listDefaultValues.add(dv9);

        if(appName == 'StateasGrantee'){
            if(applicationObj.ConstructionPackageIncluded__c == 'Construction'){
                GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TypeOfBudgetCategories__c','Construction',true);
                listDefaultValues.add(dv13);
            }
            else{
                GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TypeOfBudgetCategories__c','Non Construction',true);
                listDefaultValues.add(dv13);
            }
        }
        }
        if(appName == 'StateasGrantee'){
        GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'InternalOrganization__c',accnt.id,true);
        listDefaultValues.add(dv10);
        }
        else if(appName == 'StateasGrantor'){
        GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrganization__c',accnt.id,true);
        listDefaultValues.add(dv12);    
        }
        GNT.DynamicLayoutDefaultValueHelper dv11 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GrantsContact__c',UserInfo.getUserId(),true);
        listDefaultValues.add(dv11);  
        if(recordId!=null){
            if(grant!=null && grant.SpendType__c == 'Internal Spend') {
                GNT.DynamicLayoutDefaultValueHelper dv16 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'InternalOrganization__c',accnt.Id,true);
                listDefaultValues.add(dv16);
            }
        }      
        
        
    }
    
    public String getPageTemplateName() {
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        //String pageTemplateName = '';
        String pageTemplateName = 'Grant';
        System.debug('grant--' + grant);
        if(pageDataHolder == null && recordId == null && appName != null && appName == 'StateasGrantor'){
          pageTemplateName = 'GrantIntermediateLayout';
        } else if(recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Sub Awards' && grant.ExternalOrgName__c != 'USBE'){
          pageTemplateName = 'Grant';
        } else if(recordId == null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Sub Awards' && grant.ExternalOrgName__c == 'USBE'){
          pageTemplateName = 'USBEGrant';
        } else if(recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Contracts'){
          pageTemplateName = 'ContractGrant';
        } else if(recordId == null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Contracts'){
          pageTemplateName = 'ContractGrant';
        } else if(recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Internal Spend'){
          pageTemplateName = 'InternalSpendGrant';
        } else if(recordId == null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Internal Spend'){
          pageTemplateName = 'InternalSpendGrant';
        }else if(recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'ISA'){
          pageTemplateName = 'ISASpend';
        } else if(recordId == null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'ISA'){
          pageTemplateName = 'ISASpend';
        } else if(appName != null && appName == 'StateasGrantee'){
          pageTemplateName = 'GranteeGrants';
        }
        return pageTemplateName;
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('UserId',UserInfo.getUserId());    
        keyValueMap.put('grantId',ApexPages.currentPage().getParameters().get('id')); 
        return JSON.serialize(keyValueMap);
    }
}