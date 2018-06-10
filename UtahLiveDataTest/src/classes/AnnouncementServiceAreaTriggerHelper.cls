global with sharing class AnnouncementServiceAreaTriggerHelper extends GNT.TriggerHelper{
    global override void processBeforeDelete(){
        preventDelete();
    }
    
    private void preventDelete(){
        List<Id> annIdList = new List<Id>();
        Set<Id> annIdSet = new Set<Id>();
        Map<Id, Set<id>> anndIdToSAIdMap = new Map<Id, Set<id>>();
        for(AnnouncementServiceArea__c annSA : (List<AnnouncementServiceArea__c>)trigger.old){
            annIdSet.add(annSA.Announcement__c);
            Set<Id> annSAIdSet = anndIdToSAIdMap.get(annSA.Announcement__c);
            if(annSAIdSet == null){
                annSAIdSet = new Set<Id>();
            }
            annSAIdSet.add(annSA.Id);
            anndIdToSAIdMap.put(annSA.Announcement__c, annSAIdSet);
        }
        annIdList.addAll(annIdSet);
        List<Announcement__c> annList = [Select Id, Status__c, AnnouncementType__c From Announcement__c Where Id IN : annIdList AND AnnouncementType__c = 'Sole Source' AND Status__c = 'Active'];
        for(Announcement__c ann : annList){
            Set<Id> annSASet = anndIdToSAIdMap.get(ann.Id);
            if(annSASet != null){
                for(Id annSA : annSASet){
                    //trigger.oldMap.get(annSA).addError('Can not remove Service area as the Funding Opportunity is Published.');
                    trigger.oldMap.get(annSA).addError(GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-07571'));
                }
            }
        }
    }
}