public with sharing class CampaignCtrl {
    public Campaign__c campaignRecord{get;set;}
    public ID recordId{get;set;}
    public ID parentId{get;set;}
    public String templateName{get;set;}
    public PageReference savePage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String campaignBody{get;set;}
    public CampaignCtrl() {
    }
    public CampaignCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        parentId = ApexPages.CurrentPage().getParameters().get('parentId');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RelatedRecordId__c',parentId,true);
        //if(recordId != NULL){
          //  campaignRecord =[Select Id,Body__c,CampaignNo__c from Campaign__c where Id =:recordId limit 1]; 
           // GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('Name','anc',true);
        //}
        listDefaultValues.add(dv);
        templateName = 'Campaign';  
        savePage = Page.CampaignView;     
        savePage.getParameters().put('id', recordId);   
    }
    
    public string getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        List<String> addedIdList = new List<String>();
        List<String> sentIdList = new List<String>();
        List<String> addGroupIdsList = new List<String>();
        String addedIds,sentIds,addGroupIds;
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        campaignRecord = [Select Id,Name,Subject__c,Body__c,AddedEmailIds__c,SentEmailIds__c,AddedGroupIds__c from Campaign__c where Id =:recordId]; 
        addedIds = campaignRecord.AddedEmailIds__c;
        sentIds = campaignRecord.SentEmailIds__c;
        addGroupIds = campaignRecord.AddedGroupIds__c;
        if(addedIds != NULL){
            addedIdList = (List<String>)JSON.deserializeStrict(addedIds,List<String>.class);
        }
        if(sentIds != NULL) 
            sentIdList = (List<String>)JSON.deserializeStrict(sentIds,List<String>.class);
        if(addGroupIds != NULL) 
            addGroupIdsList = (List<String>)JSON.deserializeStrict(addGroupIds,List<String>.class);
        keyValueMap.put('SentIds',sentIdList);
        keyValueMap.put('AddedIds',addedIdList);
        keyValueMap.put('AddedGroupIds',addGroupIdsList);
        return JSON.serialize(keyValueMap);
    }
    
    public String getBody(){
        List<Campaign__c> campaignRecord =[Select Id,Body__c from Campaign__c where Id =:recordId limit 1]; 
        if (campaignRecord.size() > 0){
            campaignBody = GNT.AppUtils.replaceMergeFields(campaignRecord[0].Body__c,campaignRecord[0].Id);         // need to recheck.
        }
        return campaignBody;
    }
    
}