/*
    This class executes methods for Viewing term & condition
    **********************************************************
    Audit History
    **********************************************************
    2014-05-19   Nakul Kadam       Created
    **********************************************************  
*/
public with sharing class TermConditionViewCtrl{

    public ID recordId {get;set;}
    public String recordType {get;set;}
    public String templateName{get;set;}
    public GNT__PageTemplate__c template;
    public List<TermCondition__c> grantIds {get;set;}
    public Id grantId {get;set;}
    
    public TermConditionViewCtrl(ApexPages.StandardController stdController) {    
        recordId = ApexPages.CurrentPage().getParameters().get('id');
       
        TermCondition__c tempObj = (TermCondition__c)stdController.getRecord();
        if(recordId != null) {
            grantIds = [SELECT Grant__c,Id FROM TermCondition__c WHERE Id =: recordId];
            grantId = grantIds[0].Grant__c;
        }

        TermCondition__c tAndC = [SELECT Id,SubmissionPackage__r.GNT__PageTemplateConfig__c FROM TermCondition__c WHERE Id=:recordId];
        if(stdController.getId() != null){ // View mode
            recordType =  Schema.SObjectType.TermCondition__c.getRecordTypeInfosById().get(tempObj.RecordTypeId).getName().toLowercase();
            
        }
       
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        

        if(recordType == 'term'){
            String termType=ApexPages.CurrentPage().getParameters().get('termType');
            if(termType=='Master')
            {
            templateName = 'Grantor Master Terms and Conditions';
            }
            else
            {
            templateName = 'Grantor Terms and Conditions';        
            }
            
        }else if(recordType == 'reporting requirement'){
            templateName = 'Grantee Reporting Requirements';
        }
        else if(recordType == 'site visit' && appName != null && appName == 'StateAsGrantee'){
            templateName = 'Grantee Site Visits';
        }
        else if(recordType == 'site visit' && appName != null && appName == 'StateAsGrantor'){
            templateName = 'Grantor Site Visits';
        }
        else if((recordType == 'condition' || recordType == 'reporting requirement')&& appName != null && appName != 'StateAsGrantee' ){
            templateName = 'ConditionsTemplate';
        }else if(recordType == 'payment request' || recordType == 'paymentrequest' || recordType.contains('progress') || recordType.contains('site')){
            templateName = 'ProgramsPaymentRequestsTemplate';//'TermConditionScheduleTemplate';
        } 
      
         
    }
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('termConditionId',recordId);
            keyValueMap.put('grantId',grantId);
            
        }
        return JSON.serialize(keyValueMap);
    }
    
    public string getListParams(){
        Map<String,List<String>> listParams = new Map<String,List<String>>();
        List<String> str = new List<String>();
        str.add(templateName);
        listParams.put('templateName',str);
        return JSON.serialize(listParams);
    }
}