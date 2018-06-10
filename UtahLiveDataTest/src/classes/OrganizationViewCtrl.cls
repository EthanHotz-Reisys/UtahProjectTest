/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
public with sharing class OrganizationViewCtrl {

    public ID recordId {get;set;}
    public ID accountid {get;set;}
    public String type {get;set;}
    public String recordType {get;set;}
    public String ein {get;set;}
    public String templateName{get;set;} 
    public Document doc{get;set;}
    public ID docID{get;set;}
    
    public OrganizationViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        if(recordId == null) {
            User loggedInUser = [Select AccountId,OrganizationAccountName__c,GNT__OrganizationId__c From User Where id = :UserInfo.getUserId()];
            recordId = loggedInUser.AccountId;
        }
        //Shah CRF: Duplicate SOQL statements on account object. These could be combined with the above user object SOQL
          List<Account> accnt = [select id,name,EINText__c from Account where id=:recordId limit 1];
          system.debug('debug here'+accnt);
          System.debug('recordId '+recordId);
        recordType = [SELECT RecordType.Name FROM Account WHERE Id=:recordId].RecordType.Name;
        ein = accnt[0].EINText__c;
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        doc=[Select id,developername from Document where developername = 'FederalAssurances' LIMIT 1];
        docID=doc.ID;
        if(recordType == 'Internal') {
            templateName = 'GranteeOrganizationInternal';
        } else if(recordType == 'Recipient') {
            templateName = 'GranteeOrganizationRecipient';
        } else {
            templateName = 'GranteeOrganizationExternal';    
        }
    }
    
    public string getKeyValueMap() {
        Map<String,String> keyValueMap = new Map<String,String>();
        System.debug(' >>>the Debug Log is <<<< '+recordId);
        keyValueMap.put('orgId', recordId);
        keyValueMap.put('ein', ein);
        keyValueMap.put('docID',docID);
        return JSON.serialize(keyValueMap);
    }
}