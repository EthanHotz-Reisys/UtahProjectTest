public with sharing class OrganizationEditCtrl {
    
    public ID recordId {get;set;}
    public String orgType {get;set;}
    public String recordType {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String templateName{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public OrganizationEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        //If the Account is being created, only an Internal user can create it. Default it to Internal when no Id is present
        if(recordId != null) {
            recordType = [SELECT RecordType.Name FROM Account WHERE Id=:recordId].RecordType.Name;
            savePage = Page.OrganizationView;
            savePage.getParameters().put('id', recordId);
            cancelPage = Page.OrganizationView;
            cancelPage.getParameters().put('id', recordId);
        } else {
            recordType = 'Internal';
            orgType = ApexPages.CurrentPage().getParameters().get('type');
            populateLayoutDefaultValues();  
        }

        if(appName == 'StateasGrantee') {
            if(recordType == 'Internal')
                templateName = 'GranteeOrganizationInternal';
            else if(recordType == 'Recipient')
                templateName = 'GranteeOrganizationRecipient';
            else
                templateName = 'GranteeOrganizationExternal';                
        } else if(appName == 'Recipient' || appName == 'StateasGrantor') {
            if(recordType == 'Recipient'){
                 templateName = 'GranteeOrganizationRecipient';
            }
            else if(recordType == 'Internal'){
                templateName = 'GranteeOrganizationInternal';
            }
        } else{
            if(recordType == 'Internal')
                templateName = 'GranteeOrganizationInternal';
            else
                templateName = 'GranteeOrganizationExternal';     
        }
        System.debug('templateName------' + templateName);  
    }
    
    /*
        Populate the default values only for a new record
    */
    public void populateLayoutDefaultValues() {
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        //GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Type',orgType,true);
        //listDefaultValues.add(dv);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('orgId',recordId);
        return JSON.serialize(keyValueMap);
    }
}