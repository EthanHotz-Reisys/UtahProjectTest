/*
    Trigger Helper class for Review Panel Template Object
    ***********************************************************
    Audit History
    ***********************************************************
    11/17/2014      Nakul         Created
    *********************************************************** 
*/
public with sharing class ReviewPanelTemplateTriggerHelper extends GNT.TriggerHelper{
    public static Boolean skipTrigger= false;
    public override void processBeforeInsert(){
    	if(skipTrigger == false){
        setGroupId();
    	}
    }
    
    public override void processBeforeUpdate(){
    	if(skipTrigger == false){
       setGroupId();
    	}
    }
    
     public override void processAfterInsert() 
     
    { if(skipTrigger == false){
    	CloneReviewPanelUserTemplates();
    }
    }
    
    /*
        Auto populate the grp Id using the group name.
    */
    private void setGroupId(){
        Set<String> grpNameSet = new Set<String>();
        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        
        for(ReviewPanelTemplate__c panelTemplate : (List<ReviewPanelTemplate__c>) trigger.new){
            grpNameSet.add(panelTemplate.GroupName__c);
        }
        
        List<Group> grpList = [Select Id, DeveloperName From Group Where DeveloperName = :grpNameSet AND type = 'Queue'];
        for(Group grp : grpList){
            groupNameToIdMap.put(grp.DeveloperName, grp.Id);
        }
        
        for(ReviewPanelTemplate__c panelTemplate : (List<ReviewPanelTemplate__c>) trigger.new){
            panelTemplate.GroupId__c = groupNameToIdMap.get(panelTemplate.GroupName__c);
        }
        
    }
    //To get all Panel User templates related to Review Panel
    private void CloneReviewPanelUserTemplates(){
           System.debug('CloneReviewPanelUserTemplates--->>>');
    	Map<Id, ReviewPanelTemplate__c> rptMap = new Map<Id, ReviewPanelTemplate__c>([SELECT Id,Name,RecordTypeId,ReviewStepTemplate__c,
        																				ReviewPackage__c,Sequence__c,Description__c,ClonedFrom__c                                                                                         
                                                                                        FROM ReviewPanelTemplate__c
                                                                                        WHERE Id IN :Trigger.NewMap.keyset()]);
       System.debug('rptMap--->>>'+rptMap);
       Map<Id,Id> ClonedFromIdMap = new Map<Id,Id>();
        for(ReviewPanelTemplate__c rpt:rptMap.values()){
            ClonedFromIdMap.put(rpt.ClonedFrom__c,rpt.Id);
        }
        System.debug('ClonedFromIdMap--->>>'+ClonedFromIdMap);
        Map<Id,PanelUserTemplate__c> putMap = new Map<Id,PanelUserTemplate__c>([SELECT Id,Name,Reviewer__c,ReviewPanelTemplate__c 
        																		FROM PanelUserTemplate__c
        																		WHERE ReviewPanelTemplate__c IN :ClonedFromIdMap.keySet()]);
        System.debug('putMap--->>>'+putMap);
        List<PanelUserTemplate__c> putList = new List<PanelUserTemplate__c>();
        for(PanelUserTemplate__c paneluser :putMap.values()){
        	PanelUserTemplate__c pusertempl = new PanelUserTemplate__c();
        	pusertempl.Name = paneluser.Name;
        	pusertempl.Reviewer__c = paneluser.Reviewer__c;
        	pusertempl.ReviewPanelTemplate__c = ClonedFromIdMap.get(paneluser.ReviewPanelTemplate__c);
        	putList.add(pusertempl);
        }
        SystemContextMethodsHelper ctxtHelper  = new SystemContextMethodsHelper();
        ctxtHelper.insertPanelUserTemplates(putList);
        System.debug('putList--->>>'+putList);
    }
}