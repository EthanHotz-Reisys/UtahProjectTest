global with sharing class AddCampaignMemberActionHelper extends GNT.FlexTableActionHandler {
    public Id campaignId {get;set;}
    global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        campaignId = urlParams.get('id');
        String ids;
        Set<String> addedIdSet,sentIdSet,selectedIdSet,addedGroupSet; 
        try{
            if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){                                                 
                Campaign__c campaignRecord = [Select Name,AddedGroupIds__c,AddedEmailIds__c,SentEmailIds__c from Campaign__c where Id =:campaignId];            
                String objId = (String)selectedRecordIds[0];
                if(objId.startsWith('00G')){
                    ids = JSON.serialize(selectedRecordIds);
                    selectedIdSet = (Set<String>)JSON.deserializeStrict(ids,Set<String>.class);
                    if(campaignRecord.AddedGroupIds__c == NULL){
                        campaignRecord.AddedGroupIds__c = ids;
                    }else{
                    addedGroupSet = (Set<String>)JSON.deserializeStrict(campaignRecord.AddedGroupIds__c,Set<String>.class); 
                        for(String id : selectedIdSet){
                            if(!addedGroupSet.contains(id))
                                addedGroupSet.add(id);
                        }
                        ids = JSON.serialize(addedGroupSet);
                        campaignRecord.AddedGroupIds__c = ids;
                    }
                    List<GroupMember> grpMems = [Select UserOrGroupId from GroupMember where GroupId  IN :selectedRecordIds];
                    List<Id> userIds = new List<Id>();
                    for(GroupMember groupMem : grpMems){
                        System.debug('======>>>'+objId);
                        String uId = (String)groupMem.UserOrGroupId;
                        if(uId.startsWith('005')){
                            userIds.add(uId);
                        }
                    }
                    
                    if(userIds.size() > 0){
                        selectedRecordIds = userIds;
                    } 
                    resultMap.put('Message','Groups added successfully.');                   
                }else if(objId.startsWith('005') || objId.startsWith('003')){
                    resultMap.put('Message','Members added successfully.');                   
                }
                ids = JSON.serialize(selectedRecordIds);
                selectedIdSet = (Set<String>)JSON.deserializeStrict(ids,Set<String>.class);
                if(campaignRecord.AddedEmailIds__c == NULL){
                    campaignRecord.AddedEmailIds__c = ids;
                }else{
                    addedIdSet = (Set<String>)JSON.deserializeStrict(campaignRecord.AddedEmailIds__c,Set<String>.class); 
                    for(String id : selectedIdSet){
                        if(!addedIdSet.contains(id))
                            addedIdSet.add(id);
                    }
                    ids = JSON.serialize(addedIdSet);
                    //ids = '' + addedIdSet;
                    campaignRecord.AddedEmailIds__c = ids;
                }    
                update campaignRecord;
               
            }else{
                resultMap.put('Error','Please select atleast one record.');
            }
        }catch(System.LimitException e){
            resultMap.put('Error','Something went wrong. Please contact your administrator.');     
        }
        return resultMap;   
    } 
}