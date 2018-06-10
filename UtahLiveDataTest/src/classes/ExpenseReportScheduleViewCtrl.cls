public with sharing class ExpenseReportScheduleViewCtrl {
    //Properties
    //public String phaseId{get;set;}
    public String flexTableHeader {get;set;}
    public String termConditionId {get;set;}
    public ExpenseReportScheduleViewCtrl(){
        //phaseId = ApexPages.CurrentPage().getParameters().get('id');        
        flexTableHeader  = 'Expense Report Schedule';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
       TermConditionSchedule__c tcs = [SELECT Id,TermAndCondition__c 
                                        FROM TermConditionSchedule__c 
                                        WHERE TermAndCondition__r.SubmissionType__c = 'Payment Request' LIMIT  1];
        system.debug('tcs: '+termConditionId);
        termConditionId = tcs.TermAndCondition__c;                              
        keyValueMap.put('termConditionId', termConditionId);    
        return JSON.serialize(keyValueMap);
    }
    
   /* public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        Set<String> flexTableIdSet = new Set<String>();
        List<Id> flexTableIds = new List<Id>();
        if(phaseId != null && phaseId != '') {
            Map<Id,GNT__SearchConfig__c> flexTableMap = new Map<Id,GNT__SearchConfig__c>([SELECT Id,FlexTableConfig__c
                                                                                FROM GNT__SearchConfig__c 
                                                                                WHERE PhaseConfig__r.Id =: phaseId]);           
            Set<String> fTabIdSet = new Set<String>();
            for(GNT__SearchConfig__c ftab: flexTableMap.values()){
                fTabIdSet.add((String)ftab.FlexTableConfig__c);    
            }
            listParams.put('searchFlexTables',fTabIdSet);               
        }
        return JSON.serialize(listParams);        
    }*/
}