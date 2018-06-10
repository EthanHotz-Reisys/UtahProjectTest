/**
* CLASS TO ASSIGN REVIEWERS TO APPLICATIONS From Panels
*
* CHANGE HISTORY
*================================================================ 
* 10/16/2014    Nakul Kadam            Created 
*================================================================
*/

public with sharing class ReviewPanelAssignmentAddCtrl {
    //Properties
    public String panelId{get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;}
    private Id panelAppId{get;set;}
    
    public ReviewPanelAssignmentAddCtrl(){
        panelId = ApexPages.CurrentPage().getParameters().get('panelId');
        panelAppId =  ApexPages.currentPage().getParameters().get('id');
        reviewPanel = [SELECT Id, Name,ReviewStep__c, UserType__c, RecordType.DeveloperName 
        				FROM ReviewPanel__c WHERE Id=:panelId];
		PanelApplication__c panelApp = [Select Application__r.Name, PreApplication__r.Name From PanelApplication__c Where Id = :panelAppId];
        if(reviewPanel.RecordType.DeveloperName == 'Application'){
            flexTableHeader  = 'Assign Users for Application - '+panelApp.Application__r.Name;
        }else{
            flexTableHeader  = 'Assign Users for Pre-Application - '+panelApp.PreApplication__r.Name;
        }
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('id',panelAppId);
        keyValueMap.put('panelId',panelId);   
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(panelId != null && panelId != ''){
            Set<Id> addedUsers = getAssignedPanelUsers();
            Map<Id,PanelUser__c> panelUsersMap = new Map<Id,PanelUser__c>([SELECT Id,Reviewer__c
                                                                           FROM PanelUser__c 
                                                                           WHERE ReviewPanel__c =:panelId AND ID NOT IN :addedUsers]);            
            Set<String> panelUserIdSet = new Set<String>();
            for(Id panelUserId: panelUsersMap.keySet()){                
                panelUserIdSet.add((String)panelUserId);    
            }
            listParams.put('panelUsers',panelUserIdSet);
        }

        return JSON.serialize(listParams);
    }
    
    private Set<Id> getAssignedPanelUsers(){
        Set<Id> userIds = new Set<Id>();
        for(Review__c review: [SELECT PanelUser__c, PanelUser__r.Reviewer__c FROM Review__c 
            WHERE ReviewPanel__c = :panelId AND PanelApplication__c =: panelAppId]){
                        
            userIds.add(review.PanelUser__c);
        }        
        return userIds;
    }
}