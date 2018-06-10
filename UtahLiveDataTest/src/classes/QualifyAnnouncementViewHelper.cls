/*global with sharing class QualifyAnnouncementViewHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){      
        Id recordId = layoutHolder.getPrimarySObject().Id;
        String ns = AppUtils.getNamespacePrefix(); 
        OpportunityQualification__c oppQualifyObj;
    	PageReference pageRef = null;
        oppQualifyObj = [Select id, FundingOpportunity__c from OpportunityQualification__c where id = :recordId Limit 1];
	    if(oppQualifyObj != null && oppQualifyObj.FundingOpportunity__c != null){
	        	pageRef = new PageReference('/apex/'+ns+'AnnouncementView?id='+oppQualifyObj.FundingOpportunity__c);
	    }
	    return pageRef;
    }
}*/
global with sharing class QualifyAnnouncementViewHelper extends GNT.FlexTableActionHandler{
	

	 global override Map<String,Object> clickHandler(){
	 	PageReference pageRef = null;
	 	String ns = AppUtils.getNamespacePrefix();
	 	Map<String,Object> resultMap = new Map<String,Object>();
	 	// Check if the selectec records are already qualified or not
	 	List<OpportunityQualification__c> oppQualifyObjList = [Select id, FundingOpportunity__c from OpportunityQualification__c where FundingOpportunity__c in :selectedRecordIds];
		 system.debug('--oppQualifyObjList--'+oppQualifyObjList);
		 	if(oppQualifyObjList != null && oppQualifyObjList.size() > 0){
				 //resultMap.put('Message','Selected Oppourtunities are already qualified.');
				 resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-47369'));
                return resultMap;
		
	 		}
	 		else
	 		{
	 			 		qualifyAnnouncements(selectedRecordIds);

	 		}
	 	

	 	 //resultMap.put('Message','Selected Oppourtunities have been marked as qualified.');
	 	 resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61052'));
                return resultMap;
	 }

	 global void qualifyAnnouncements(List<Id> annIdList)
	 {
	 	 Id accountId;
	 	  OpportunityQualification__c oppQualifyObj;
	 	 User userObj = [Select Contact.AccountId From User where Id =:UserInfo.getUserId()];
          if(userObj.Contact.AccountId != null){
            accountId = [Select id from Account where Id =: userObj.Contact.AccountId].Id;  
            System.Debug('accountId...'+accountId);
          }

          List<OpportunityQualification__c> qualAnnList = new List<OpportunityQualification__c>();
          for(Id annId : annIdList)
          {

          	oppQualifyObj = new OpportunityQualification__c();
            oppQualifyObj.Account__c=accountId;
            oppQualifyObj.FundingOpportunity__c=annId;
            qualAnnList.add(oppQualifyObj);

          }

          if(qualAnnList.size()>0)
          {

          	insert qualAnnList;
          }

	 }
}