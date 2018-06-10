/**
* CLASS TO ASSIGN APPLICATION TO REVIEWER From Panels
*
* CHANGE HISTORY
*================================================================ 
* 09/04/2015    Nakul Kadam            Created 
*================================================================
*/

public with sharing class AssignApplicationsToReviewerCtrl {
    //Properties
    public String panelId{get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;}
    private Id panelUserId{get;set;}
    
    public AssignApplicationsToReviewerCtrl(){
        panelId = ApexPages.CurrentPage().getParameters().get('panelId');
        panelUserId =  ApexPages.currentPage().getParameters().get('id');
        reviewPanel = [SELECT Id, Name,ReviewStep__c, UserType__c, RecordType.DeveloperName FROM ReviewPanel__c WHERE Id=:panelId];
        
        PanelUser__c panelUser = [Select Reviewer__r.Name From PanelUser__c Where Id = : panelUserId];
        if(reviewPanel.RecordType.DeveloperName == 'Application'){
            flexTableHeader  = 'Assign Applications for User - ' +panelUser.Reviewer__r.Name;
        } else {
            flexTableHeader  = 'Assign Pre-Applications for User - ' +panelUser.Reviewer__r.Name;
        }      
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('id',panelUserId);
        keyValueMap.put('panelId',panelId);   
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(panelId != null && panelId != ''){
            Set<Id> addedApps = getAssignedPanelApplications();
            Map<Id,PanelApplication__c> panelAppsMap = new Map<Id,PanelApplication__c>([SELECT Id,Application__c
                                                                           FROM PanelApplication__c 
                                                                           WHERE ReviewPanel__c =:panelId AND ID NOT IN :addedApps]);            
            Set<String> panelAppIdSet = new Set<String>();
            for(Id panelAppId: panelAppsMap.keySet()){                
                panelAppIdSet.add((String)panelAppId);    
            }
            listParams.put('panelApps',panelAppIdSet);
        }

        return JSON.serialize(listParams);
    }
    
    private Set<Id> getAssignedPanelApplications(){
        Set<Id> appIds = new Set<Id>();
        for(Review__c review: [SELECT PanelApplication__c FROM Review__c 
            WHERE ReviewPanel__c = :panelId AND PanelUser__c =: panelUserId]){  
            appIds.add(review.PanelApplication__c);
        }
        return appIds;
    }
}