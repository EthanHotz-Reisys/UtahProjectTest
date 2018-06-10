/**
* Class to handle the ProgramEdit page
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 02/05/2014    Kunal Shah      Created
* 03/10/2015    William Moore   Merged SOQL statements
* =============================================================================
*/

public with sharing class ProgramEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    private Account accnt;
    public ProgramEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        User u = [SELECT Id, AccountNameFormulaField__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> programOwner = new List<User>(); 
        programOwner = [select GNT__OrganizationId__c from user where Id = :UserInfo.getUserId()];        
        accnt = [Select id from Account where id=:(ID)programOwner[0].GNT__OrganizationId__c];   
        String recordtype = ApexPages.CurrentPage().getParameters().get('RecordType');
        RecordType recordType1;
        if(recordtype!=null)
        recordType1 = [Select Id,DeveloperName from RecordType where DeveloperName =:recordtype and sObjectType =: AppUtils.getNamespacePrefix()+'Program__c'];
        savePage = Page.ProgramView;
        savePage.getParameters().put('id', recordId);
        if (cancelPage == null && recordId != null) {
            cancelPage = Page.ProgramView;  
            cancelPage.getParameters().put('id', recordId); 
        } else {
            String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            if(retURL != null) {
                cancelPage = new PageReference(retURL);    
            }
        }
        Id programid =  ApexPages.CurrentPage().getParameters().get('programid');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(accnt.id!=null){
        GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Account__c',accnt.id,true);
        listDefaultValues.add(dv4);
        }
        if (programid != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ParentProgram__c',programid,true);
            listDefaultValues.add(dv);   
        }
        if (programid != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ParentProgram__c',programid,true);
            listDefaultValues.add(dv);   
        }
        if(recordtype!=null){
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType1.Id,true);
            listDefaultValues.add(dv1);
            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FunderType__c','Federal',true);
            listDefaultValues.add(dv2); 
            GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgramType__c','Grant',true);
            listDefaultValues.add(dv3);
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgramSubType__c','Project Grants',true);
            listDefaultValues.add(dv4); 
           }
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(u.AccountNameFormulaField__c != 'USBE' && u.AccountNameFormulaField__c != 'SYSTEM'){
            pageTemplateName = 'Grantee State Program';  
        }else{
            pageTemplateName = 'USBE Program';
        }
        
        // Pankaj : In add program case we dont have recordId.
        if(recordId != null ) {
            List<Program__c> ProgramList = [select id,name,recordtype.name, Account__r.Name from Program__c WHERE id=:recordId];
            String recType = ProgramList[0].recordtype.name;
            if(ProgramList[0].Account__r.Name == 'USBE'){
                pageTemplateName = 'USBE Program';
            }else{
                if(recType == 'Internal Program'){
                    pageTemplateName = 'Grantee State Program';
                }
                if(recType == 'NGO Program'){
                    pageTemplateName = 'NGO Program';
                    
                }
             
                if(recType == 'External Program'){
                    pageTemplateName = 'Federal Program';
                }
            }                 
        }
    }
    
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('UserId',UserInfo.getUserId());    
        keyValueMap.put('programid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('UserId',UserInfo.getUserId());  
        return JSON.serialize(keyValueMap);
    }
  
}