global with sharing class RemoveCampaignGroupActionHelper extends GNT.FlexTableActionHandler {
    public Id campaignId {get;set;}
    String addedGroupIds;
    Set<String> sentGroupIdSet,addedGroupIdSet;  
    global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        campaignId = urlParams.get('id'); 
        try{
            if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            Campaign__c campaignRecord = [Select Name,AddedGroupIds__c from Campaign__c where Id =:campaignId]; 
            addedGroupIds = campaignRecord.AddedGroupIds__c;
            if(addedGroupIds != NULL){
            addedGroupIdSet = (Set<String>)JSON.deserializeStrict(addedGroupIds,Set<String>.class);
            for(String id : selectedRecordIds){
                if(addedGroupIdSet.contains(id)){
                    addedGroupIdSet.remove(id); 
                }
            }
            String ids = JSON.serialize(addedGroupIdSet);
            campaignRecord.AddedGroupIds__c = ids;
            update campaignRecord; 
                resultMap.put('Message','Group removed successfully.');
            }else{
                resultMap.put('Message','You have not added members to list.');
            }
            }else{
            resultMap.put('Error','Please select atleast one record.');
            }
        }catch(System.LimitException e){
            resultMap.put('Error','Something went wrong. Please contact your administrator.');     
        }
        return resultMap;    
    }
}