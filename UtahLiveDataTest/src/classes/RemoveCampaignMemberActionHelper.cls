global with sharing class RemoveCampaignMemberActionHelper extends GNT.FlexTableActionHandler {
    public Id campaignId {get;set;}
    String addedIds;
    Set<String> sentIdSet,addedIdSet;  
    global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        campaignId = urlParams.get('id'); 
        try{
            if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            Campaign__c campaignRecord = [Select Name,AddedEmailIds__c,SentEmailIds__c from Campaign__c where Id =:campaignId]; 
            addedIds = campaignRecord.AddedEmailIds__c;
            if(addedIds != NULL){
            addedIdSet = (Set<String>)JSON.deserializeStrict(addedIds,Set<String>.class);
            for(String id : selectedRecordIds){
                if(addedIdSet.contains(id)){
                    addedIdSet.remove(id); 
                }
            }
            String ids = JSON.serialize(addedIdSet);
            campaignRecord.AddedEmailIds__c = ids;
            update campaignRecord; 
                resultMap.put('Message','Members removed successfully.');
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