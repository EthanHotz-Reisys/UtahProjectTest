public with sharing class AddPanelApplicationCtrl {
	public String panelId {get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;}
    public String reviewStepId {get;set;}
    public String tableName {get;set;}
    Map<String,Object> resultMap = new Map<String,Object>();

	public AddPanelApplicationCtrl() {
		panelId = ApexPages.CurrentPage().getParameters().get('panelId');
        reviewPanel = [SELECT Id, Name, ReviewStep__c, UserType__c, RecordType.DeveloperName FROM ReviewPanel__c WHERE Id=:panelId];
        reviewStepId = reviewPanel.ReviewStep__c;
        
	}
    //ReviewStep__c revStep = [SELECT StepNumber__c,Status__c FROM ReviewStep__c WHERE id =:reviewStepId];
    
    /*if(revStep.StepNumber__c == 2 && revStep.Status__c!= 'In Progress'){
        resultMap.put('Message', 'Please initiate the review step before adding the applications.');
        return resultMap;
    }else{
        tableName ='AddPanelApplication';
    }*/

	public String getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(panelId != null && panelId != ''){
            Set<Id> addedApps = getAddedReviewStepApplication();
            Map<Id,ReviewStepApplication__c> reviewStepAppsMap = new Map<Id,ReviewStepApplication__c>([SELECT Id, Application__c
                                                                           FROM ReviewStepApplication__c 
                                                                           WHERE ReviewStep__c =:reviewStepId AND Application__c NOT IN :addedApps]);            
            Set<String> reviewStepAppIdSet = new Set<String>();
            for(Id reviewStepAppId: reviewStepAppsMap.keySet()){                
                reviewStepAppIdSet.add((String)reviewStepAppId);    
            }
            listParams.put('reviewStepApps',reviewStepAppIdSet);
        }

        return JSON.serialize(listParams);
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('panelId',panelId);   
        return JSON.serialize(keyValueMap);
    }
    
    private Set<Id> getAddedReviewStepApplication(){
        Set<Id> appIds = new Set<Id>();
        List<ReviewPanel__c> rps = [Select Id, (Select Id, Application__c from Panel_Applications__r) from ReviewPanel__c where ReviewStep__c = :reviewStepId];
        for(ReviewPanel__c rp : rps){
            for(PanelApplication__c pa : rp.Panel_Applications__r){
                appIds.add(pa.Application__c);
            }
        }
        //for(PanelApplication__c pa: [SELECT Application__c FROM PanelApplication__c 
        //    WHERE ReviewPanel__c = :panelId]){  
        //    appIds.add(pa.Application__c);
        //}
        return appIds;
    }
}