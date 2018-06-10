public with sharing class PanelApplicationAddCtrl{
    
    //Properties
    public String panelId{get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;} 
    public String recordType{get;set;}
    
    public PanelApplicationAddCtrl(){
        panelId = ApexPages.CurrentPage().getParameters().get('id');
        reviewPanel = [SELECT Id, Name,ReviewStep__c,RecordTypeId,RecordType.Name, RecordType.DeveloperName, PanelName__c
                         FROM ReviewPanel__c WHERE Id=:panelId];
        recordType = reviewPanel.RecordType.Name;
        flexTableHeader  = 'Add Applications to Panel - ' + reviewPanel.PanelName__c;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();      
        keyValueMap.put('reviewPanelId', panelId);          
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(panelId != null && panelId != ''){
           
            Map<Id,PanelApplication__c> panelApplicationsMap = new Map<Id,PanelApplication__c>([SELECT Id,Application__c,PreApplication__c,
                                                                                RecordTypeId
                                                                                FROM PanelApplication__c
                                                                                    WHERE ReviewPanel__c =:panelId]);
            Set<String> existingPanelApplsIdSet = new Set<String>();
            Set<String> existingPanelPreApplsIdSet = new Set<String>();
            
            Id paRecTypeIdApp = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id paRecTypeIdPreApp = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            for(PanelApplication__c panelApplication: panelApplicationsMap.values()){
                if(panelApplication.RecordTypeId == paRecTypeIdApp){
                    existingPanelApplsIdSet.add((String)panelApplication.Application__c); 
                }else if(panelApplication.RecordTypeId == paRecTypeIdPreApp){
                    existingPanelPreApplsIdSet.add((String)panelApplication.PreApplication__c); 
                }  
            }            
            Id rpRecTypeIdApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
            Id rpRecTypeIdPreApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
            
            if(reviewPanel.RecordTypeId == rpRecTypeIdApp){
                Map<Id,ReviewStepApplication__c> reviewStepApplicationMap = new Map<Id,ReviewStepApplication__c>([SELECT Id,Name,Application__c,Preapplication__c
                                                                                    FROM ReviewStepApplication__c
                                                                                        WHERE ReviewStep__c =:reviewPanel.ReviewStep__c
                                                                                            AND Application__c NOT IN:existingPanelApplsIdSet]);
                Set<String> panelApplicationIdSet = new Set<String>();
                for(ReviewStepApplication__c reviewStepApplication: reviewStepApplicationMap.values()){
                    panelApplicationIdSet.add((String)reviewStepApplication.Id);    
                }
                listParams.put('stepApplications',panelApplicationIdSet);
            }else if(reviewPanel.RecordTypeId == rpRecTypeIdPreApp){
                Map<Id,ReviewStepApplication__c> reviewStepApplicationMap = new Map<Id,ReviewStepApplication__c>([SELECT Id,Name,Application__c,Preapplication__c
                                                                                    FROM ReviewStepApplication__c
                                                                                        WHERE ReviewStep__c =:reviewPanel.ReviewStep__c
                                                                                            AND Preapplication__c NOT IN:existingPanelPreApplsIdSet]);
                Set<String> panelPreApplicationIdSet = new Set<String>();
                for(ReviewStepApplication__c reviewStepApplication: reviewStepApplicationMap.values()){
                    panelPreApplicationIdSet.add((String)reviewStepApplication.Id);    
                }
                listParams.put('stepApplications',panelPreApplicationIdSet);
            }        
        }

        return JSON.serialize(listParams);
    }
    
}