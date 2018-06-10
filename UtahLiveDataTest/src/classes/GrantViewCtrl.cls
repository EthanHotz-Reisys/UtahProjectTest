/**
* View page controller for the Grant__c object
*
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/19/2014    Kunal Shah   Created
* =============================================================================
*/


public with sharing class GrantViewCtrl {

    public ID recordId {get; set;}
    private Grant__c grant;
    public PageReference deleteURL {get; set;}
    public String pageTemplateName {get; set;}
    public GrantViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        if (recordId != null) {
            grant = [SELECT Id, Name, SpendType__c, Program__c, USBEPathway__c, ExternalOrgName__c FROM Grant__c WHERE Id = :recordId];
        }
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if (grant.USBEPathway__c == 'MSP' || grant.USBEPathway__c == 'LSNA') {
            pageTemplateName = 'MSPGrantView';
        } 
        else if (recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Contracts') {
            pageTemplateName = 'ContractGrant';
        } 
        else if (recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'Internal Spend') {
            pageTemplateName = 'InternalSpendGrant';
        } 
        else if (recordId != null && appName != null && appName == 'StateasGrantor' && grant.SpendType__c == 'ISA') {
            pageTemplateName = 'ISASpend';
        } 
        else if (recordId != null && (appName == 'Recipient' || appName == 'StateasGrantor') && grant.SpendType__c == 'Sub Awards' && grant.ExternalOrgName__c != 'USBE') {
            pageTemplateName = 'Grant';
        }
        else if (recordId != null && (appName == 'Recipient' || appName == 'StateasGrantor') && grant.SpendType__c == 'Sub Awards' && grant.ExternalOrgName__c == 'USBE') {
            pageTemplateName = 'USBEGrant';
        } 
        else if (appName != null && appName == 'StateasGrantee') {
            pageTemplateName = 'GranteeGrants';
        }
        deleteURL = null;
    }

    public string getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        keyValueMap.put('grantId', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('id', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('UserId', UserInfo.getUserId());
        keyValueMap.put('programId', grant.Program__c);
        keyValueMap.put('name', grant.Name);
        return JSON.serialize(keyValueMap);
    }

    public void updateStatus() {
        EventHandlerCtrl ctrl = new EventHandlerCtrl();
        ctrl.updateStatus();
    }
}