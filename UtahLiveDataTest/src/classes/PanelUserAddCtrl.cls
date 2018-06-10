public with sharing class PanelUserAddCtrl{
    
    //Properties
    public String panelId{get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;}
    public PanelUserAddCtrl(){
        panelId = ApexPages.CurrentPage().getParameters().get('id');
        reviewPanel = [SELECT Id, Name,ReviewStep__c,UserType__c,PanelName__c FROM ReviewPanel__c WHERE Id=:panelId];
        flexTableHeader  = 'Add Reviewers to Panel - ' + reviewPanel.PanelName__c;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('reviewPanelId', panelId);    
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(panelId != null && panelId != ''){
            Map<Id,PanelUser__c> panelUsersMap = new Map<Id,PanelUser__c>([SELECT Id,Reviewer__c
                                                                                FROM PanelUser__c 
                                                                                     WHERE ReviewPanel__c =:panelId]);
            system.debug('panelUsersMap: '+ panelUsersMap);
            Set<String> panelUserIdSet = new Set<String>();
            for(PanelUser__c panelUser: panelUsersMap.values()){
                panelUserIdSet.add((String)panelUser.Reviewer__c);    
            }
            system.debug('panelUserIdSet: '+ panelUserIdSet);
            Map<Id,User> userMap;
            if(reviewPanel.UserType__c == 'Internal'){
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND OrganizationAccountName__c <> ''
                                    AND UserType='Standard' AND IsActive = true AND IsReviewer__c = true Order by Name LIMIT 1000]);
            }else if(reviewPanel.UserType__c == 'External'){
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND OrganizationAccountName__c <> ''
                                    AND UserType!='Standard' AND IsActive = true AND IsReviewer__c = true Order by Name LIMIT 1000]);
            }else{
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND OrganizationAccountName__c <> ''
                                    AND IsActive = true AND IsReviewer__c = true Order by Name LIMIT 1000]);
            }
            system.debug('UserMap: '+userMap +'>>>>>>'+reviewPanel.UserType__c);
            Set<String> userIdSet = new Set<String>();
            for(Id userId : userMap.keySet()){
                userIdSet.add((String)userId);    
            }           
            listParams.put('panelUsers',userIdSet);
        }

        return JSON.serialize(listParams);
    }
    
}