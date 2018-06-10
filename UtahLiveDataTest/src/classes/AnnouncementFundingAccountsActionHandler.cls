global with sharing class AnnouncementFundingAccountsActionHandler extends GNT.FlexTableActionHandler {
   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
         Id parentId = urlParams.get('parentid');     
         String AnnouncementFA = urlParams.get('type');
         List<AnnouncementFundingAccount__c> annfundingaccnts = new List<AnnouncementFundingAccount__c>();
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            for(Id recordId: selectedRecordIds){
                AnnouncementFundingAccount__c annfndaccnt = new AnnouncementFundingAccount__c();
                annfndaccnt.FundingAccount__c = recordId;
                annfndaccnt.Announcement__c = parentId;
                annfundingaccnts.add(annfndaccnt);
            }
            insert(annfundingaccnts);           
            PageReference pageRef = new PageReference('/apex/SelectRecordsPopUp?parentid='+parentId+'&flextable=SelectAnnFundingAccounts&type='+AnnouncementFA); 
      		pageRef.getParameters().put('id',parentId);
      		resultMap.put('PageReference',pageRef);
      		//resultMap.put('Message','Funding Accounts added succesfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-23183'));
         }else{
            //resultMap.put('Message','No records are selected.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
         }
        
        return resultMap;   
    }
}