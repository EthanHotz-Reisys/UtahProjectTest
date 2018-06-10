public with sharing class ReviewPanelViewCtrl{

    public ID recordId {get;set;}
    public String recordType {get;set;}
    public String pageHeader {get;set;}
    public string templateName {get;set;}
    private ReviewPanel__c rstObj{get; set;} 
    private List<Id> userList{get;set;}
    
    public ReviewPanelViewCtrl(ApexPages.StandardController stdController) {     
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        if(stdController.getId() != null){ // View mode
            rstObj = [select id,Name,ReviewStep__c,RecordTypeId,PanelLayout__r.Name from ReviewPanel__c where id =: recordId limit 1];
            recordType =  Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosById().get(rstObj.RecordTypeId).getName().toLowercase();
            pageHeader += '-' + rstObj.Name;
            //templateName = rstObj.PanelLayout__r.Name;
            templateName = 'Review Panel Application Template';
            List<PanelUser__c> panelUsers =[Select Id, Name, Reviewer__r.name, Reviewer__r.Id from PanelUser__c where ReviewPanel__c=:recordId];
            userList=new List<Id>();
            for(PanelUser__c pu : panelUsers)            {
                userList.add(pu.Reviewer__r.Id);
            }
        }
        
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('reviewPanelId',ApexPages.CurrentPage().getParameters().get('id')); 
        keyValueMap.put('reviewStepId',rstObj.ReviewStep__c); 
       // keyValueMap.put('userList',userList); 

        return JSON.serialize(keyValueMap);
    }


     public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        
        if(recordId != null){
            ReviewPanel__c rPanel = [select Id, Name,ReviewStep__c,ReviewStep__r.PreventDuplicateReviewers__c,UserType__c,PanelName__c,ReviewStep__r.DepartmentName__c FROM ReviewPanel__c where Id =: recordId limit 1];
            Map<Id,PanelUser__c> panelUsersMap;
            if(rPanel.ReviewStep__r.PreventDuplicateReviewers__c == true) {
                panelUsersMap = new Map<Id,PanelUser__c>([SELECT Id,Reviewer__c
                                                                FROM PanelUser__c 
                                                                WHERE ReviewPanel__r.ReviewStep__c =:rPanel.ReviewStep__c]);
            }else if(rPanel.ReviewStep__r.PreventDuplicateReviewers__c == false) {
                panelUsersMap = new Map<Id,PanelUser__c>([SELECT Id,Reviewer__c
                                                                FROM PanelUser__c 
                                                                WHERE ReviewPanel__c =:recordId]);
            }
            Set<String> panelUserIdSet = new Set<String>();
            for(PanelUser__c panelUser: panelUsersMap.values()){
                panelUserIdSet.add((String)panelUser.Reviewer__c);
            }
            
            Map<Id,User> userMap;
            
            String deptName = rPanel.ReviewStep__r.DepartmentName__c;
            
            if(rPanel.UserType__c == 'Internal'){
                userMap = new Map<Id,User>([SELECT Id FROM User WHERE Id NOT IN:panelUserIdSet 
                                    AND UserType = 'Standard' AND IsActive = true AND AccountNameFormulaField__c =: deptName
                                    Order by Name LIMIT 1000]);
            }else if(rPanel.UserType__c == 'External'){
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