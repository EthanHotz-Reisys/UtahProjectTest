global with sharing class AddApplicationsToPanelHelper  extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix();
              
        Id panelId = urlParams.get('panelId');      
        ReviewPanel__c reviewPanel = [SELECT Id, Name,ReviewStep__c FROM ReviewPanel__c WHERE Id=:panelId];
        Id revStepId = reviewPanel.ReviewStep__c;
        ReviewStep__c revStp = [SELECT Id, Name, Status__c, StepNumber__c FROM ReviewStep__c WHERE Id=:revStepId];
        Map<Id,ReviewStepApplication__c> rsaMap = new Map<Id,ReviewStepApplication__c>([SELECT Id,Name,TotalScore__c,NumberOfSMEReviews__c,
                                                                Application__c,Preapplication__c,RecordTypeId 
                                                                FROM ReviewStepApplication__c
                                                                WHERE Id IN :selectedRecordIds]);         
        List<PanelApplication__c> panelApplicationList = new List<PanelApplication__c>();
        
        Id rsaRecTypeIdApp = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();        
        Id rsaRecTypeIdPreApp = Schema.SObjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();        
        
        Id paRecTypeIdApp = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id paRecTypeIdPreApp = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        
        if(revStp.StepNumber__c == 2 && revStp.Status__c != 'In Progress'){
            resultMap.put('Message','Please initiate the review step before adding the applications.');
            return resultMap;
        }
        
        for(String selectedId:selectedRecordIds){
            PanelApplication__c panelApplication = new PanelApplication__c();
            if(rsaMap.get(selectedId).RecordTypeId == rsaRecTypeIdApp){
                panelApplication.Application__c = rsaMap.get(selectedId).Application__c ;
                panelApplication.TotalScore__c = rsaMap.get(selectedId).TotalScore__c;
                panelApplication.NumberOfReviews__c = rsaMap.get(selectedId).NumberOfSMEReviews__c;
                panelApplication.RecordTypeId = paRecTypeIdApp;
            }else if(rsaMap.get(selectedId).RecordTypeId == rsaRecTypeIdPreApp){
                panelApplication.PreApplication__c = rsaMap.get(selectedId).Preapplication__c;
                panelApplication.RecordTypeId = paRecTypeIdPreApp;
            }
            panelApplication.ReviewPanel__c = panelId;
            panelApplicationList.add(panelApplication);
        }
                
        
        if(Schema.sObjectType.PanelApplication__c.isCreateable()){
            insert panelApplicationList;
        }

        resultMap.put('PageReference',null);
        
        resultMap.put('Message','Applications have been successfully added to the panel.');
        resultMap.put('Type', 'success');

        return resultMap;
    }    
}