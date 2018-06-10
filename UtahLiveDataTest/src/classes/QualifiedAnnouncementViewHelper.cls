global with sharing class QualifiedAnnouncementViewHelper extends GNT.FlexTableActionHandler{
       
       global override Map<String,Object> clickHandler(){
             PageReference pageRef = null;
             String ns = AppUtils.getNamespacePrefix();
             Map<String,Object> resultMap = new Map<String,Object>();
             List<OpportunityQualification__c> oppQualifyObjList = [Select id, FundingOpportunity__c from OpportunityQualification__c where id in :selectedRecordIds];
                   if(oppQualifyObjList != null && oppQualifyObjList.size() > 0){
                         OpportunityQualification__c oppQualifyObj = oppQualifyObjList[0];
                         if(oppQualifyObj != null && oppQualifyObj.FundingOpportunity__c != null){
                          pageRef = new PageReference('/apex/'+ns+'QualifiedOpportunityView?id='+oppQualifyObj.Id+'&announcementid='+oppQualifyObj.FundingOpportunity__c);
                    }
             }
             resultMap.put('PageReference',pageRef);
             return resultMap;
       }
}