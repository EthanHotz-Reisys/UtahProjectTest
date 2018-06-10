public with sharing class PanelExternalUserAddCtrl{
    
    //Properties
    public String panelId{get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;}
    public String flexTableName {get;set;} 
    
    public PanelExternalUserAddCtrl(){
        panelId = ApexPages.CurrentPage().getParameters().get('id');
        reviewPanel = [SELECT Id, Name,ReviewStep__c,UserType__c,PanelName__c, ReviewStep__r.DepartmentName__c FROM ReviewPanel__c WHERE Id=:panelId];
        flexTableHeader  = 'Add Reviewers to Panel - ' + reviewPanel.PanelName__c;
        if(reviewPanel.UserType__c == 'External'){
            flexTableName = 'PanelExternalUserAdd';
        }else{
            flexTableName = 'PanelUserAdd';
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('reviewPanelId', panelId);    
        return JSON.serialize(keyValueMap);
    }

    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(panelId != null && panelId != ''){
            ReviewPanel__c rPanel = [select ReviewStep__c,ReviewStep__r.PreventDuplicateReviewers__c FROM ReviewPanel__c where Id =: panelId limit 1];
            //ReviewStep__c rStep = [Select id,PreventDuplicateReviewers__c from ReviewStep__c where id =: rPanel.ReviewStep__c];
            Map<Id,PanelUser__c> panelUsersMap;
            if(rPanel.ReviewStep__r.PreventDuplicateReviewers__c == true) {
                panelUsersMap = new Map<Id,PanelUser__c>([SELECT Id,Reviewer__c
                                                                FROM PanelUser__c 
                                                                WHERE ReviewPanel__r.ReviewStep__c =:rPanel.ReviewStep__c]);
            }else if(rPanel.ReviewStep__r.PreventDuplicateReviewers__c == false) {
                panelUsersMap = new Map<Id,PanelUser__c>([SELECT Id,Reviewer__c
                                                                FROM PanelUser__c 
                                                                WHERE ReviewPanel__c =:panelId]);
            }
            Set<String> panelUserIdSet = new Set<String>();
            for(PanelUser__c panelUser: panelUsersMap.values()){
                panelUserIdSet.add((String)panelUser.Reviewer__c);
            }
            
            Map<Id,User> userMap;
            
            String deptName = reviewPanel.ReviewStep__r.DepartmentName__c;
            
            if(reviewPanel.UserType__c == 'Internal'){
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND UserType = 'Standard' AND IsActive = true AND AccountNameFormulaField__c =: deptName
                                    Order by Name LIMIT 1000]);
            }else if(reviewPanel.UserType__c == 'External'){
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND ((UserType='Standard') OR (UserType='PowerPartner' and IsReviewer__c=true))  Order by Name LIMIT 1000]);
            }else{
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND AccountNameFormulaField__c =: deptName
                                    AND IsActive = true Order by Name LIMIT 1000]);
            }
            
            Set<String> userIdSet = new Set<String>();
            for(Id userId : userMap.keySet()){
                userIdSet.add((String)userId);    
            }           
            listParams.put('panelUsers',userIdSet);
        }

        return JSON.serialize(listParams);
    }
    
}